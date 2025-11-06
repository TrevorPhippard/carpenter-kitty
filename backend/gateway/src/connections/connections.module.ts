import { Module } from "@nestjs/common";
import { HttpModule } from "@nestjs/axios"; // <-- use @nestjs/axios
import { ConnectionsService } from "./connections.service";
import { ConnectionsController } from "./connections.controller";

@Module({
  imports: [HttpModule],
  providers: [ConnectionsService],
  controllers: [ConnectionsController],
})
export class ConnectionsModule {}
