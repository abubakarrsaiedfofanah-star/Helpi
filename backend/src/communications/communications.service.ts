import { Injectable, ServiceUnavailableException } from '@nestjs/common';

@Injectable()
export class CommunicationsService {
  async createRoom(): Promise<never> {
    // A provider adapter must create an authorized room and return short-lived
    // participant tokens. A configured API key alone does not make calls work.
    throw new ServiceUnavailableException(
      'Voice and video calling are not configured for this deployment.',
    );
  }
}
