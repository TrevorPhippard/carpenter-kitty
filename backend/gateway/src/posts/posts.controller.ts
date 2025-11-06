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
