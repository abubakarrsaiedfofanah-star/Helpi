-- Helpi Supabase setup, part 3 of 3. Run parts in order.

-- Run each part once in a NEW project. If a part fails, fix that part before continuing.

BEGIN;


-- AddForeignKey
ALTER TABLE "RefreshSession" ADD CONSTRAINT "RefreshSession_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "EmailVerificationToken" ADD CONSTRAINT "EmailVerificationToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "PasswordResetToken" ADD CONSTRAINT "PasswordResetToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "SecurityEvent" ADD CONSTRAINT "SecurityEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "PayoutDestination" ADD CONSTRAINT "PayoutDestination_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "PayoutApproval" ADD CONSTRAINT "PayoutApproval_destinationId_fkey" FOREIGN KEY ("destinationId") REFERENCES "PayoutDestination"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "PayoutApproval" ADD CONSTRAINT "PayoutApproval_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "FraudSignal" ADD CONSTRAINT "FraudSignal_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "FraudSignal" ADD CONSTRAINT "FraudSignal_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "DocumentCheck" ADD CONSTRAINT "DocumentCheck_evidenceId_fkey" FOREIGN KEY ("evidenceId") REFERENCES "CaseEvidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "IdentityVerification" ADD CONSTRAINT "IdentityVerification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "InstitutionVerification" ADD CONSTRAINT "InstitutionVerification_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "SanctionsScreening" ADD CONSTRAINT "SanctionsScreening_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "SanctionsScreening" ADD CONSTRAINT "SanctionsScreening_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "FraudGraphEdge" ADD CONSTRAINT "FraudGraphEdge_fromId_fkey" FOREIGN KEY ("fromId") REFERENCES "FraudGraphNode"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "FraudGraphEdge" ADD CONSTRAINT "FraudGraphEdge_toId_fkey" FOREIGN KEY ("toId") REFERENCES "FraudGraphNode"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "DeviceRegistration" ADD CONSTRAINT "DeviceRegistration_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "CommunicationRoom" ADD CONSTRAINT "CommunicationRoom_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "CommunicationRoom" ADD CONSTRAINT "CommunicationRoom_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "SafeguardingCase" ADD CONSTRAINT "SafeguardingCase_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "SafeguardingCase" ADD CONSTRAINT "SafeguardingCase_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "PaymentAttempt" ADD CONSTRAINT "PaymentAttempt_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "Transaction"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "PaymentAttempt" ADD CONSTRAINT "PaymentAttempt_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "PaymentProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "OrganizationMember" ADD CONSTRAINT "OrganizationMember_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "OrganizationMember" ADD CONSTRAINT "OrganizationMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpCircle" ADD CONSTRAINT "HelpCircle_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpCircleMember" ADD CONSTRAINT "HelpCircleMember_circleId_fkey" FOREIGN KEY ("circleId") REFERENCES "HelpCircle"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpCircleMember" ADD CONSTRAINT "HelpCircleMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Appeal" ADD CONSTRAINT "Appeal_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Appeal" ADD CONSTRAINT "Appeal_appellantId_fkey" FOREIGN KEY ("appellantId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Appeal" ADD CONSTRAINT "Appeal_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Project" ADD CONSTRAINT "Project_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "ProjectMilestone" ADD CONSTRAINT "ProjectMilestone_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "CountryConfiguration" ADD CONSTRAINT "CountryConfiguration_updatedById_fkey" FOREIGN KEY ("updatedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "_ThreadParticipants" ADD CONSTRAINT "_ThreadParticipants_A_fkey" FOREIGN KEY ("A") REFERENCES "MessageThread"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "_ThreadParticipants" ADD CONSTRAINT "_ThreadParticipants_B_fkey" FOREIGN KEY ("B") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- Enforce one account per email regardless of casing or surrounding whitespace.
CREATE UNIQUE INDEX "User_email_normalized_key" ON "User" (LOWER(BTRIM("email")));

-- Initial country settings used by the app and admin country-operations screens.
INSERT INTO "CountryConfiguration" (
  "id", "countryCode", "enabled", "defaultLanguage", "languages", "currencies",
  "paymentMethods", "kycRequirements", "kybRequirements", "safeguardingRules",
  "emergencyResources", "documentTypes", "dataRetention", "helpMethods",
  "verificationRules", "communicationRules", "updatedById", "createdAt", "updatedAt"
) SELECT
  'country-' || country.code, country.code, TRUE, 'en',
  '["en"]'::jsonb,
  CASE WHEN country.currency IS NULL THEN '[]'::jsonb ELSE jsonb_build_array(country.currency) END,
  '[]'::jsonb,
  '{"identityRequired":true,"acceptedDocumentTypes":[]}'::jsonb,
  '{"enabled":true,"requiredForOrganizations":true,"documents":[]}'::jsonb,
  '{"childSafetyReview":true,"exactAddressesPublic":false,"escalationRequired":true}'::jsonb,
  '[]'::jsonb,
  '[]'::jsonb,
  '{"identityDays":2555,"caseDays":2555,"financialDays":2555,"deletionRequestWorkflow":true}'::jsonb,
  '["MONEY","GOODS","SKILLS","TIME","TRANSPORT","SERVICES"]'::jsonb,
  '{"identity":true,"need":true,"institution":true,"paymentDestination":true,"humanReview":true}'::jsonb,
  '{"translation":true,"voice":true,"video":true,"childContactRequiresSafeguards":true}'::jsonb,
  NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
  ('DZ', 'DZD'),
  ('AO', 'AOA'),
  ('BJ', 'XOF'),
  ('BW', 'BWP'),
  ('BF', 'XOF'),
  ('BI', 'BIF'),
  ('CV', 'CVE'),
  ('CM', 'XAF'),
  ('CF', 'XAF'),
  ('TD', 'XAF'),
  ('KM', 'KMF'),
  ('CG', 'XAF'),
  ('CD', 'CDF'),
  ('CI', 'XOF'),
  ('DJ', 'DJF'),
  ('EG', 'EGP'),
  ('GQ', 'XAF'),
  ('ER', 'ERN'),
  ('SZ', 'SZL'),
  ('ET', 'ETB'),
  ('GA', 'XAF'),
  ('GM', 'GMD'),
  ('GH', 'GHS'),
  ('GN', 'GNF'),
  ('GW', 'XOF'),
  ('KE', 'KES'),
  ('LS', 'ZAR'),
  ('LR', 'LRD'),
  ('LY', 'LYD'),
  ('MG', 'MGA'),
  ('MW', 'MWK'),
  ('ML', 'XOF'),
  ('MR', 'MRU'),
  ('MU', 'MUR'),
  ('MA', 'MAD'),
  ('MZ', 'MZN'),
  ('NA', 'ZAR'),
  ('NE', 'XOF'),
  ('NG', 'NGN'),
  ('RW', 'RWF'),
  ('ST', 'STN'),
  ('SN', 'XOF'),
  ('SC', 'SCR'),
  ('SL', 'SLE'),
  ('SO', 'SOS'),
  ('ZA', 'ZAR'),
  ('SS', 'SSP'),
  ('SD', 'SDG'),
  ('TZ', 'TZS'),
  ('TG', 'XOF'),
  ('TN', 'TND'),
  ('UG', 'UGX'),
  ('ZM', 'ZMW'),
  ('ZW', 'USD'),
  ('AQ', NULL),
  ('AF', 'AFN'),
  ('AM', 'AMD'),
  ('AZ', 'AZN'),
  ('BH', 'BHD'),
  ('BD', 'BDT'),
  ('BT', 'INR'),
  ('BN', 'BND'),
  ('KH', 'KHR'),
  ('CN', 'CNY'),
  ('CY', 'EUR'),
  ('GE', 'GEL'),
  ('IN', 'INR'),
  ('ID', 'IDR'),
  ('IR', 'IRR'),
  ('IQ', 'IQD'),
  ('IL', 'ILS'),
  ('JP', 'JPY'),
  ('JO', 'JOD'),
  ('KZ', 'KZT'),
  ('KP', 'KPW'),
  ('KR', 'KRW'),
  ('KW', 'KWD'),
  ('KG', 'KGS'),
  ('LA', 'LAK'),
  ('LB', 'LBP'),
  ('MY', 'MYR'),
  ('MV', 'MVR'),
  ('MN', 'MNT'),
  ('MM', 'MMK'),
  ('NP', 'NPR'),
  ('OM', 'OMR'),
  ('PK', 'PKR'),
  ('PS', 'ILS'),
  ('PH', 'PHP'),
  ('QA', 'QAR'),
  ('SA', 'SAR'),
  ('SG', 'SGD'),
  ('LK', 'LKR'),
  ('SY', 'SYP'),
  ('TJ', 'TJS'),
  ('TH', 'THB'),
  ('TL', 'USD'),
  ('TM', 'TMT'),
  ('TR', 'TRY'),
  ('AE', 'AED'),
  ('UZ', 'UZS'),
  ('VN', 'VND'),
  ('YE', 'YER'),
  ('AL', 'ALL'),
  ('AD', 'EUR'),
  ('AT', 'EUR'),
  ('BY', 'BYN'),
  ('BE', 'EUR'),
  ('BA', 'BAM'),
  ('BG', 'BGN'),
  ('HR', 'EUR'),
  ('CZ', 'CZK'),
  ('DK', 'DKK'),
  ('EE', 'EUR'),
  ('FI', 'EUR'),
  ('FR', 'EUR'),
  ('DE', 'EUR'),
  ('GR', 'EUR'),
  ('VA', 'EUR'),
  ('HU', 'HUF'),
  ('IS', 'ISK'),
  ('IE', 'EUR'),
  ('IT', 'EUR'),
  ('LV', 'EUR'),
  ('LI', 'CHF'),
  ('LT', 'EUR'),
  ('LU', 'EUR'),
  ('MT', 'EUR'),
  ('MD', 'MDL'),
  ('MC', 'EUR'),
  ('ME', 'EUR'),
  ('NL', 'EUR'),
  ('MK', 'MKD'),
  ('NO', 'NOK'),
  ('PL', 'PLN'),
  ('PT', 'EUR'),
  ('RO', 'RON'),
  ('RU', 'RUB'),
  ('SM', 'EUR'),
  ('RS', 'RSD'),
  ('SK', 'EUR'),
  ('SI', 'EUR'),
  ('ES', 'EUR'),
  ('SE', 'SEK'),
  ('CH', 'CHF'),
  ('UA', 'UAH'),
  ('GB', 'GBP'),
  ('AG', 'XCD'),
  ('BS', 'BSD'),
  ('BB', 'BBD'),
  ('BZ', 'BZD'),
  ('CA', 'CAD'),
  ('CR', 'CRC'),
  ('CU', 'CUP'),
  ('DM', 'XCD'),
  ('DO', 'DOP'),
  ('SV', 'USD'),
  ('GD', 'XCD'),
  ('GT', 'GTQ'),
  ('HT', 'HTG'),
  ('HN', 'HNL'),
  ('JM', 'JMD'),
  ('MX', 'MXN'),
  ('NI', 'NIO'),
  ('PA', 'PAB'),
  ('KN', 'XCD'),
  ('LC', 'XCD'),
  ('VC', 'XCD'),
  ('TT', 'TTD'),
  ('US', 'USD'),
  ('AU', 'AUD'),
  ('FJ', 'FJD'),
  ('KI', 'AUD'),
  ('MH', 'USD'),
  ('FM', 'USD'),
  ('NR', 'AUD'),
  ('NZ', 'NZD'),
  ('PW', 'USD'),
  ('PG', 'PGK'),
  ('WS', 'WST'),
  ('SB', 'SBD'),
  ('TO', 'TOP'),
  ('TV', 'AUD'),
  ('VU', 'VUV'),
  ('AS', 'USD'),
  ('AI', 'XCD'),
  ('AW', 'AWG'),
  ('BM', 'BMD'),
  ('BQ', 'USD'),
  ('BV', 'NOK'),
  ('IO', 'USD'),
  ('KY', 'KYD'),
  ('CX', 'AUD'),
  ('CC', 'AUD'),
  ('CK', 'NZD'),
  ('CW', 'XCG'),
  ('FK', 'FKP'),
  ('FO', 'DKK'),
  ('GF', 'EUR'),
  ('PF', 'XPF'),
  ('TF', 'EUR'),
  ('GI', 'GIP'),
  ('GL', 'DKK'),
  ('GP', 'EUR'),
  ('GU', 'USD'),
  ('GG', 'GBP'),
  ('HM', 'AUD'),
  ('HK', 'HKD'),
  ('IM', 'GBP'),
  ('JE', 'GBP'),
  ('MO', 'MOP'),
  ('MQ', 'EUR'),
  ('YT', 'EUR'),
  ('MS', 'XCD'),
  ('NC', 'XPF'),
  ('NU', 'NZD'),
  ('NF', 'AUD'),
  ('MP', 'USD'),
  ('PN', 'NZD'),
  ('PR', 'USD'),
  ('RE', 'EUR'),
  ('BL', 'EUR'),
  ('SH', 'SHP'),
  ('MF', 'EUR'),
  ('PM', 'EUR'),
  ('SX', 'XCG'),
  ('GS', 'GBP'),
  ('SJ', 'NOK'),
  ('TW', 'TWD'),
  ('TK', 'NZD'),
  ('TC', 'USD'),
  ('UM', 'USD'),
  ('VG', 'USD'),
  ('VI', 'USD'),
  ('WF', 'XPF'),
  ('EH', 'MAD'),
  ('AX', 'EUR'),
  ('AR', 'ARS'),
  ('BO', 'BOB'),
  ('BR', 'BRL'),
  ('CL', 'CLP'),
  ('CO', 'COP'),
  ('EC', 'USD'),
  ('GY', 'GYD'),
  ('PY', 'PYG'),
  ('PE', 'PEN'),
  ('SR', 'SRD'),
  ('UY', 'UYU'),
  ('VE', 'VES')
) AS country(code, currency)
ON CONFLICT ("countryCode") DO UPDATE SET "currencies" = EXCLUDED."currencies";

-- Keep the public Supabase Data API closed to anonymous/authenticated client roles.
-- The API server connects as the database owner and performs authorization itself.
DO $helpi_enable_rls$
DECLARE
  target RECORD;
BEGIN
  FOR target IN
    SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', 'public', target.tablename);
  END LOOP;
END;
$helpi_enable_rls$;


COMMIT;