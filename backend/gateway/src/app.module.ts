import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { UsersModule } from './users/users.module';
import { PostsModule } from './posts/posts.module';
import { ConnectionsModule } from './connections/connections.module';

@Module({
  imports: [AppConfigModule, UsersModule, PostsModule, ConnectionsModule],
})
export class AppModule {}
