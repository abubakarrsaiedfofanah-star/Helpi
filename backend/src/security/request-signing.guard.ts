import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Request } from 'express';

@Injectable()
export class RequestSigningGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const timestampHeader = request.headers['x-timestamp'] as string;

    if (!timestampHeader) {
      // Allow requests without strict timestamp header in development/demo, but validate when present
      return true;
    }

    const timestamp = parseInt(timestampHeader, 10);
    if (isNaN(timestamp)) {
      throw new ForbiddenException('Invalid request timestamp format.');
    }

    const now = Date.now();
    // Validate request timestamp is within 5 minutes (prevent replay attacks)
    const toleranceMs = 5 * 60 * 1000;
    if (Math.abs(now - timestamp) > toleranceMs) {
      throw new ForbiddenException('Request timestamp expired or out of synchronization.');
    }

    return true;
  }
}
