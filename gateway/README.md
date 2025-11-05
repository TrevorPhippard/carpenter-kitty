# User & Profile Service

## Overview

This service manages user accounts, authentication, and profiles. It handles profile creation, updates, and connections between users.

## Technology Stack

- Language: Go
- Database: PostgreSQL
- Authentication: JWT / OAuth
- GraphQL: Apollo Federation compatible schema

## GraphQL Schema Highlights

```graphql
type User @key(fields: \"id\") {
  id: ID!
  profile: Profile
  connections(first: Int): [User]
}
type Profile {
  id: ID!
  firstName: String
  lastName: String
  headline: String
  experience: [Experience]
}
```

## Setup

1. Clone the repository:

   ```bash
   git clone <repo-url>
   cd user-service
   ```

2. Create a .env file based on .env.example.
3. Start the database:

   ```bash
   docker-compose up -d postgres
   ```

4. Run the service:

   ```bash
   go run main.go
   ```

## Environment Variables

- DB_HOST
- DB_PORT
- DB_USER
- DB_PASSWORD
- JWT_SECRET

## Example Queries

```graphql
query {
z
```

"
