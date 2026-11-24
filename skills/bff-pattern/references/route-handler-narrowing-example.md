# Example: A BFF Route That Narrows a Backend Response

Sources: https://nextjs.org/docs/app/api-reference/file-conventions/route · https://zod.dev/basics · https://samnewman.io/patterns/architectural/bff/ · Last verified 2026-11-24

A generic example, abstracted from an internal route-handler procedure; no internal names reused. It uses Next.js App Router and zod only as one concrete stack; the shape carries to any BFF.

## The shape of a screen-focused route
A BFF route does five things in order: authorize, validate input, call the backend, narrow the payload to what one screen needs, and map failures to a status the UI can branch on. It holds no business rules (see the parent skill).

```ts
import { z } from "zod"

const Query = z.object({ page: z.coerce.number().int().min(1).default(1) })

export async function GET(request: Request, { params }: { params: Promise<{ id: string }> }) {
  const principal = await requireAccess(request, "GET", "/api/orders/[id]") // 401/403/404 handled inside
  if (principal instanceof Response) return principal

  const { id } = await params                       // params is a Promise in current App Router
  const q = Query.safeParse(Object.fromEntries(new URL(request.url).searchParams))
  if (!q.success) return Response.json({ errors: q.error.issues }, { status: 400 })

  const upstream = await backend.get(`/v1/orders/${id}`, { tenant: principal.tenantId })
  if (!upstream.ok) return Response.json({ code: upstream.code }, { status: upstream.status })

  const o = await upstream.json()
  return Response.json({                            // narrowed: only what this screen renders
    id: o.id, status: o.status, total: o.total_cents / 100, lines: o.lines.length,
  })
}
```

## Points the example demonstrates
1. **Validate with the safe variant.** Zod's `safeParse` returns a result object instead of throwing, so bad input is a 400, not a 500.
2. **Treat the path as input.** The identifier in the URL is user data; the tenant comes from the verified session (`principal`), never from the request, and the backend still checks ownership.
3. **Narrow the response.** Forwarding the backend payload couples the UI to the backend schema and leaks fields; map to the screen's shape. A pure proxy is fine only when both shapes are the same.
4. **Never turn an upstream failure into an empty success.** A 200 with an empty list renders as "no data" and hides a broken dependency. Propagate a status or a typed code; return a gateway error when the backend is unreachable.
5. **Keep status parity with the backend** for hide-versus-deny cases, so the edge does not reveal what the backend hides (see `authn-authz-guard`).
6. **Declare the route.** Authorization resolves from a declared route table; an undeclared route should fail closed.

## Testing
Test the handler with a stubbed backend: validation failure, backend 4xx and 5xx, unreachable backend, and the narrowed shape (assert the dropped fields are absent).

## How an agent should apply this
- Use this shape for any BFF route that serves one screen; do not add domain computation to it.
- Reject routes that pass the backend body through unchanged without a reason, or that read tenant from the request.
- Reject catch-all handlers that return 200 on upstream error.
- For fan-out to several backends, combine with the aggregation and partial-failure rules in the Newman reference.
