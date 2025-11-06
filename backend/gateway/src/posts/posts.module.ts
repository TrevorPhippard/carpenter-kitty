import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { PostsService } from './posts.service';
import { PostsController } from './posts.controller';
import { join } from 'path';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'POST_SERVICE',
        transport: Transport.GRPC,
        options: {
          package: 'post',
          protoPath: join(__dirname, '../proto/post.proto'),
          url: `${process.env.POST_SERVICE_HOST}:${process.env.POST_SERVICE_PORT}`,
        },
      },
    ]),
  ],
  providers: [PostsService],
  controllers: [PostsController],
})
export class PostsModule {}
