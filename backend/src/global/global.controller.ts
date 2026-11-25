import { Controller, Get } from '@nestjs/common';

@Controller('global')
export class GlobalController {
  @Get('capabilities')
  capabilities() {
    return {
      privacy: ['public-anonymous-alias', 'private-identity', 'consent-controls'],
      accessibility: ['screen-reader', 'large-text', 'high-contrast', 'reduced-motion'],
      connectivity: ['offline-drafts', 'low-data-mode', 'retry-queue'],
      communication: ['translation', 'voice-messages', 'voice-calls', 'video-calls'],
      help: ['financial-support-requests', 'support-groups', 'requested-amounts'],
      trust: ['account-security', 'safeguarding', 'user-controlled-public-identity'],
      safety: ['fraud-signals', 'safeguarding', 'reporting', 'appeals', 'country-configured-rules'],
      operations: ['country-configuration', 'language-coverage', 'document-types', 'data-retention', 'emergency-resources', 'help-methods'],
      publicPrivacyRule: 'Never expose an exact vulnerable-person address publicly.'
    };
  }
}
