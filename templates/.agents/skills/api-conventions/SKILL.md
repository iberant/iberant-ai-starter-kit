---
name: api-conventions
description: REST API design conventions for this project's services. Use when adding or changing HTTP endpoints.
---

# API Conventions

Loaded on demand (not in every conversation) so it does not bloat the agent's context.

- Use kebab-case for URL paths (`/user-profiles`).
- Use camelCase for JSON properties.
- Version APIs in the path (`/v1/`, `/v2/`).
- Always paginate list endpoints (`?page`, `?pageSize`, default 50, max 200).
- Return RFC 7807 problem+json for errors.
- Never return secrets or internal IDs in responses.
