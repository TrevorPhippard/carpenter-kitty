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
      catchError((err) => throwError(() => new Error(`PostService failed: ${err.message}`))),
    );
  }
}
