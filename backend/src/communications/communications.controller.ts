import { Controller, Post, UseGuards } from '@nestjs/common';
import { CommunicationsService } from './communications.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('communications')
@UseGuards(AuthGuard)
export class CommunicationsController {
  constructor(private readonly communications: CommunicationsService) {}

  @Post('room')
  room() {
    return this.communications.createRoom();
  }
}
