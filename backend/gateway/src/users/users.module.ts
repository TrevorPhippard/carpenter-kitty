import { Module } from "@nestjs/common";
import { ClientsModule, Transport } from "@nestjs/microservices";
import { UsersService } from "./users.service";
import { UsersController } from "./users.controller";
import { join, resolve } from "path";

@Module({
  imports: [
    ClientsModule.register([
      {
        name: "USER_SERVICE",
        transport: Transport.GRPC,
        options: {
          package: "user",
          protoPath: resolve(__dirname, "../../src/proto/user.proto"), // <-- absolute path to src
          url: `${process.env.USER_SERVICE_HOST}:${process.env.USER_SERVICE_PORT}`,
        },
      },
    ]),
  ],
  providers: [UsersService],
  controllers: [UsersController],
})
export class UsersModule {}
