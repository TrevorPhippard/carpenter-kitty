// lib/graphqlClient.ts
import { GraphQLClient } from 'graphql-request'

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:4000'

export const graphqlClient = new GraphQLClient(`${BASE}/graphql`, {
  headers: {
    'content-type': 'application/json',
  },
})

export async function createPost(payload: {
  userId: string
  text?: string
  content?: string
  media?: Array<string>
}) {
  const mutation = `
    mutation CreatePost($input: CreatePostInput!) {
      createPost(input: $input) {
        id
        text
        content
        media
        createdAt
        likes
        user {
          id
          fullName
          avatarUrl
        }
        commentsCount
      }
    }
  `

  const variables = {
    input: {
      userId: payload.userId,
      text: payload.text,
      content: payload.content,
      media: payload.media,
    },
  }

  const { createPost } = await graphqlClient.request(mutation, variables)
  return createPost
}
