import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { UserRole } from '@prisma/client';

@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext) {
    const req = context.switchToHttp().getRequest<any>();
    const roles: UserRole[] | undefined = Reflect.getMetadata('roles', context.getHandler()) ?? Reflect.getMetadata('roles', context.getClass());
    if (!roles?.length) return true;
    if (!roles.includes(req.user?.user?.role)) throw new ForbiddenException('Insufficient privileges.');
    return true;
  }
}
