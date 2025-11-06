#!/bin/bash
# create-nestjs-gateway.sh
# Run this script in an empty project folder
# Usage: bash create-nestjs-gateway.sh

set -e

echo "Creating NestJS API Gateway folder structure..."

# Create directories
mkdir -p src/{config,users,posts,connections,proto}

# Create root files
cat > package.json <<EOL
{
  "name": "nestjs-api-gateway",
  "version": "1.0.0",
  "scripts": {
    "start": "nest start",
    "start:dev": "nest start --watch",
    "build": "nest build"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/microservices": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/config": "^2.3.0",
    "rxjs": "^7.8.0",
    "reflect-metadata": "^0.1.13",
    "grpc": "^1.24.2",
    "@grpc/grpc-js": "^1.8.14",
    "node-fetch": "^3.3.2"
  },
  "devDependencies": {
    "typescript": "^5.2.2",
    "@nestjs/cli": "^10.0.0"
  }
}
EOL

cat > tsconfig.json <<EOL
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2020",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules"]
}
EOL

cat > .env <<EOL
USER_SERVICE_HOST=localhost
USER_SERVICE_PORT=8080

POST_SERVICE_HOST=localhost
POST_SERVICE_PORT=8081

CONNECTIONS_SERVICE_URL=http://localhost:8082/graphql
EOL

cat > Dockerfile <<EOL
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["node", "dist/main.js"]
EOL

# Config module
cat > src/config/config.module.ts <<EOL
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true })],
})
export class AppConfigModule {}
EOL

# Main entry
cat > src/main.ts <<EOL
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.listen(3000);
  console.log('🚀 API Gateway running on http://localhost:3000');
}
bootstrap();
EOL

# App module
cat > src/app.module.ts <<EOL
import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { UsersModule } from './users/users.module';
import { PostsModule } from './posts/posts.module';
import { ConnectionsModule } from './connections/connections.module';

@Module({
  imports: [AppConfigModule, UsersModule, PostsModule, ConnectionsModule],
})
export class AppModule {}
EOL

# Proto files
cat > src/proto/user.proto <<EOL
syntax = "proto3";

package user;

service UserService {
  rpc GetUser (GetUserRequest) returns (GetUserResponse);
}

message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  string id = 1;
  string name = 2;
  string email = 3;
}
EOL

cat > src/proto/post.proto <<EOL
syntax = "proto3";

package post;

service PostService {
  rpc GetPost (GetPostRequest) returns (GetPostResponse);
}

message GetPostRequest {
  string id = 1;
}

message GetPostResponse {
  string id = 1;
  string title = 2;
  string content = 3;
}
EOL

# Users module
cat > src/users/users.module.ts <<EOL
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { join } from 'path';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'USER_SERVICE',
        transport: Transport.GRPC,
        options: {
          package: 'user',
          protoPath: join(__dirname, '../proto/user.proto'),
          url: \`\${process.env.USER_SERVICE_HOST}:\${process.env.USER_SERVICE_PORT}\`,
        },
      },
    ]),
  ],
  providers: [UsersService],
  controllers: [UsersController],
})
export class UsersModule {}
EOL

cat > src/users/users.service.ts <<EOL
import { Inject, Injectable, OnModuleInit } from '@nestjs/common';
import { ClientGrpc } from '@nestjs/microservices';
import { Observable, catchError, throwError } from 'rxjs';

interface UserService {
  GetUser(data: { id: string }): Observable<{ id: string; name: string; email: string }>;
}

@Injectable()
export class UsersService implements OnModuleInit {
  private userService: UserService;

  constructor(@Inject('USER_SERVICE') private client: ClientGrpc) {}

  onModuleInit() {
    this.userService = this.client.getService<UserService>('UserService');
  }

  getUser(id: string) {
    return this.userService.GetUser({ id }).pipe(
      catchError((err) => throwError(() => new Error(\`UserService failed: \${err.message}\`))),
    );
  }
}
EOL

cat > src/users/users.controller.ts <<EOL
import { Controller, Get, Param } from '@nestjs/common';
import { UsersService } from './users.service';
import { lastValueFrom } from 'rxjs';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  async getUser(@Param('id') id: string) {
    const user = await lastValueFrom(this.usersService.getUser(id));
    return user;
  }
}
EOL

# Posts module
cat > src/posts/posts.module.ts <<EOL
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
          url: \`\${process.env.POST_SERVICE_HOST}:\${process.env.POST_SERVICE_PORT}\`,
        },
      },
    ]),
  ],
  providers: [PostsService],
  controllers: [PostsController],
})
export class PostsModule {}
EOL

cat > src/posts/posts.service.ts <<EOL
import { Inject, Injectable, OnModuleInit } from '@nestjs/common';
import { ClientGrpc } from '@nestjs/microservices';
import { Observable, catchError, throwError } from 'rxjs';

interface PostService {
  GetPost(data: { id: string }): Observable<{ id: string; title: string; content: string }>;
}

@Injectable()
export class PostsService implements OnModuleInit {
  private postService: PostService;

  constructor(@Inject('POST_SERVICE') private client: ClientGrpc) {}

  onModuleInit() {
    this.postService = this.client.getService<PostService>('PostService');
  }

  getPost(id: string) {
    return this.postService.GetPost({ id }).pipe(
      catchError((err) => throwError(() => new Error(\`PostService failed: \${err.message}\`))),
    );
  }
}
EOL

cat > src/posts/posts.controller.ts <<EOL
import { Controller, Get, Param } from '@nestjs/common';
import { PostsService } from './posts.service';
import { lastValueFrom } from 'rxjs';

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Get(':id')
  async getPost(@Param('id') id: string) {
    const post = await lastValueFrom(this.postsService.getPost(id));
    return post;
  }
}
EOL

# Connections module
cat > src/connections/connections.module.ts <<EOL
import { Module, HttpModule } from '@nestjs/common';
import { ConnectionsService } from './connections.service';
import { ConnectionsController } from './connections.controller';

@Module({
  imports: [HttpModule],
  providers: [ConnectionsService],
  controllers: [ConnectionsController],
})
export class ConnectionsModule {}
EOL

cat > src/connections/connections.service.ts <<EOL
import { Injectable, HttpService } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class ConnectionsService {
  constructor(private readonly httpService: HttpService) {}

  async getConnections(userId: string) {
    const query = \`
      query GetConnections(\$userId: ID!) {
        connections(userId: \$userId) {
          id
          name
        }
      }
    \`;
    const response = await firstValueFrom(
      this.httpService.post(process.env.CONNECTIONS_SERVICE_URL, { query, variables: { userId } }),
    );
    return response.data.data.connections;
  }
}
EOL

cat > src/connections/connections.controller.ts <<EOL
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
EOL

echo "✅ NestJS API Gateway scaffold created successfully!"