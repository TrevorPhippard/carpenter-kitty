import { Injectable } from "@nestjs/common";
import { HttpService } from "@nestjs/axios";
import { firstValueFrom, map } from "rxjs";

@Injectable()
export class ConnectionsService {
  constructor(private readonly httpService: HttpService) {}

  async getConnections(userId: string) {
    const query = `
      query GetConnections($userId: ID!) {
        connections(userId: $userId) {
          id
          name
        }
      }
    `;

    const response = await firstValueFrom(
      this.httpService
        .post(process.env.CONNECTIONS_SERVICE_URL, {
          query,
          variables: { userId },
        })
        .pipe(map((res) => res.data)) // <-- map to res.data
    );

    // Now response is typed as { data: { connections: ... } }
    return response.data.connections;
  }
}
