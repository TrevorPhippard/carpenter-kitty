import { Controller, Get, Param } from '@nestjs/common';
import { ConnectionsService } from './connections.service';

@Controller('connections')
export class ConnectionsController {
  constructor(private readonly connectionsService: ConnectionsService) {}

  @Get(':id')
  async getConnections(@Param('id') id: string) {
    return this.connectionsService.getConnections(id);
  }
}
