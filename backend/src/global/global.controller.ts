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
      help: ['money', 'goods', 'skills', 'time', 'transport', 'services'],
      trust: ['identity', 'need', 'institution', 'payment-destination', 'evidence', 'human-review'],
      payment: ['country-aware-routing', 'original-currency', 'settlement-currency', 'country-configured-payment-methods'],
      safety: ['fraud-signals', 'safeguarding', 'reporting', 'appeals', 'country-configured-rules'],
      operations: ['country-configuration', 'language-coverage', 'document-types', 'data-retention', 'emergency-resources', 'help-methods'],
      publicPrivacyRule: 'Never expose an exact vulnerable-person address publicly.'
    };
  }
}
