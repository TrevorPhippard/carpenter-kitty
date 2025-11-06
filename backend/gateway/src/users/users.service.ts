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
      catchError((err) => throwError(() => new Error(`UserService failed: ${err.message}`))),
    );
  }
}
