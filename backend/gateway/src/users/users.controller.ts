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
