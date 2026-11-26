-- Helpi Supabase setup, part 2 of 3. Run parts in order.

-- Run each part once in a NEW project. If a part fails, fix that part before continuing.

BEGIN;


-- CreateTable
CREATE TABLE "PaymentProvider" (
    "id" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "type" "PaymentProviderType" NOT NULL,
    "name" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "settlementCurrency" TEXT NOT NULL,
    "configRef" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PaymentProvider_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "PaymentAttempt" (
    "id" TEXT NOT NULL,
    "transactionId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "providerReference" TEXT,
    "status" TEXT NOT NULL DEFAULT 'CREATED',
    "requestHash" TEXT,
    "responseMeta" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PaymentAttempt_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "ExchangeRateSnapshot" (
    "id" TEXT NOT NULL,
    "baseCurrency" TEXT NOT NULL,
    "quoteCurrency" TEXT NOT NULL,
    "rate" DECIMAL(20,10) NOT NULL,
    "source" TEXT NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExchangeRateSnapshot_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "Organization" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "city" TEXT,
    "description" TEXT,
    "status" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "website" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Organization_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "OrganizationMember" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'STAFF',
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OrganizationMember_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "HelpCircle" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "purpose" TEXT,
    "goalMinor" INTEGER,
    "currency" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HelpCircle_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "HelpCircleMember" (
    "id" TEXT NOT NULL,
    "circleId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'MEMBER',
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "HelpCircleMember_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "Appeal" (
    "id" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "appellantId" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'OPEN',
    "reviewerId" TEXT,
    "reviewerNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedAt" TIMESTAMP(3),

    CONSTRAINT "Appeal_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "Project" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "city" TEXT,
    "category" TEXT NOT NULL,
    "goalMinor" INTEGER NOT NULL,
    "currency" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PLANNING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Project_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "ProjectMilestone" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "amountMinor" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "evidence" JSONB,
    "dueAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "ProjectMilestone_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "PublicImpactSnapshot" (
    "id" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "completedCases" INTEGER NOT NULL DEFAULT 0,
    "contributors" INTEGER NOT NULL DEFAULT 0,
    "amountMinor" INTEGER NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PublicImpactSnapshot_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "CountryConfiguration" (
    "id" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "defaultLanguage" TEXT NOT NULL DEFAULT 'en',
    "languages" JSONB NOT NULL,
    "currencies" JSONB NOT NULL,
    "paymentMethods" JSONB NOT NULL,
    "kycRequirements" JSONB NOT NULL,
    "kybRequirements" JSONB NOT NULL,
    "safeguardingRules" JSONB NOT NULL,
    "emergencyResources" JSONB NOT NULL,
    "documentTypes" JSONB NOT NULL,
    "dataRetention" JSONB NOT NULL,
    "helpMethods" JSONB NOT NULL,
    "verificationRules" JSONB NOT NULL,
    "communicationRules" JSONB NOT NULL,
    "updatedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CountryConfiguration_pkey" PRIMARY KEY ("id")
);


-- CreateTable
CREATE TABLE "_ThreadParticipants" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ThreadParticipants_AB_pkey" PRIMARY KEY ("A","B")
);


-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");


-- CreateIndex
CREATE INDEX "Referral_referrerId_createdAt_idx" ON "Referral"("referrerId", "createdAt");


-- CreateIndex
CREATE INDEX "HelpCase_status_createdAt_idx" ON "HelpCase"("status", "createdAt");


-- CreateIndex
CREATE INDEX "HelpCase_ownerId_idx" ON "HelpCase"("ownerId");


-- CreateIndex
CREATE INDEX "HelpCase_countryCode_category_status_idx" ON "HelpCase"("countryCode", "category", "status");


-- CreateIndex
CREATE INDEX "CaseEvidence_caseId_idx" ON "CaseEvidence"("caseId");


-- CreateIndex
CREATE INDEX "VerificationRequest_status_createdAt_idx" ON "VerificationRequest"("status", "createdAt");


-- CreateIndex
CREATE INDEX "VerificationRequest_caseId_idx" ON "VerificationRequest"("caseId");


-- CreateIndex
CREATE INDEX "HelpOffer_countryCode_status_idx" ON "HelpOffer"("countryCode", "status");


-- CreateIndex
CREATE INDEX "HelpOffer_caseId_idx" ON "HelpOffer"("caseId");


-- CreateIndex
CREATE INDEX "MessageThread_caseId_idx" ON "MessageThread"("caseId");


-- CreateIndex
CREATE INDEX "Message_threadId_createdAt_idx" ON "Message"("threadId", "createdAt");


-- CreateIndex
CREATE INDEX "Report_status_createdAt_idx" ON "Report"("status", "createdAt");


-- CreateIndex
CREATE INDEX "Notification_userId_readAt_createdAt_idx" ON "Notification"("userId", "readAt", "createdAt");


-- CreateIndex
CREATE UNIQUE INDEX "RefreshSession_tokenHash_key" ON "RefreshSession"("tokenHash");


-- CreateIndex
CREATE INDEX "RefreshSession_userId_revokedAt_idx" ON "RefreshSession"("userId", "revokedAt");


-- CreateIndex
CREATE UNIQUE INDEX "EmailVerificationToken_tokenHash_key" ON "EmailVerificationToken"("tokenHash");


-- CreateIndex
CREATE INDEX "EmailVerificationToken_userId_expiresAt_idx" ON "EmailVerificationToken"("userId", "expiresAt");


-- CreateIndex
CREATE UNIQUE INDEX "PasswordResetToken_tokenHash_key" ON "PasswordResetToken"("tokenHash");


-- CreateIndex
CREATE INDEX "PasswordResetToken_userId_expiresAt_idx" ON "PasswordResetToken"("userId", "expiresAt");


-- CreateIndex
CREATE INDEX "AuditLog_userId_createdAt_idx" ON "AuditLog"("userId", "createdAt");


-- CreateIndex
CREATE INDEX "AuditLog_action_createdAt_idx" ON "AuditLog"("action", "createdAt");


-- CreateIndex
CREATE INDEX "SecurityEvent_userId_status_createdAt_idx" ON "SecurityEvent"("userId", "status", "createdAt");


-- CreateIndex
CREATE INDEX "SecurityEvent_type_severity_createdAt_idx" ON "SecurityEvent"("type", "severity", "createdAt");


-- CreateIndex
CREATE INDEX "PayoutDestination_userId_status_idx" ON "PayoutDestination"("userId", "status");


-- CreateIndex
CREATE INDEX "PayoutDestination_destinationHash_idx" ON "PayoutDestination"("destinationHash");


-- CreateIndex
CREATE UNIQUE INDEX "PayoutDestination_userId_destinationHash_key" ON "PayoutDestination"("userId", "destinationHash");


-- CreateIndex
CREATE INDEX "PayoutApproval_destinationId_createdAt_idx" ON "PayoutApproval"("destinationId", "createdAt");


-- CreateIndex
CREATE UNIQUE INDEX "Transaction_providerReference_key" ON "Transaction"("providerReference");


-- CreateIndex
CREATE UNIQUE INDEX "Transaction_idempotencyKey_key" ON "Transaction"("idempotencyKey");


-- CreateIndex
CREATE INDEX "Transaction_userId_createdAt_idx" ON "Transaction"("userId", "createdAt");


-- CreateIndex
CREATE INDEX "Transaction_caseId_status_createdAt_idx" ON "Transaction"("caseId", "status", "createdAt");


-- CreateIndex
CREATE INDEX "FraudSignal_status_severity_createdAt_idx" ON "FraudSignal"("status", "severity", "createdAt");


-- CreateIndex
CREATE INDEX "FraudSignal_caseId_idx" ON "FraudSignal"("caseId");


-- CreateIndex
CREATE INDEX "PaymentWebhookEvent_payloadHash_idx" ON "PaymentWebhookEvent"("payloadHash");


-- CreateIndex
CREATE UNIQUE INDEX "PaymentWebhookEvent_providerReference_eventType_key" ON "PaymentWebhookEvent"("providerReference", "eventType");


-- CreateIndex
CREATE UNIQUE INDEX "DocumentCheck_evidenceId_key" ON "DocumentCheck"("evidenceId");


-- CreateIndex
CREATE INDEX "IdentityVerification_userId_status_idx" ON "IdentityVerification"("userId", "status");


-- CreateIndex
CREATE INDEX "InstitutionVerification_caseId_status_idx" ON "InstitutionVerification"("caseId", "status");


-- CreateIndex
CREATE INDEX "SanctionsScreening_status_createdAt_idx" ON "SanctionsScreening"("status", "createdAt");


-- CreateIndex
CREATE UNIQUE INDEX "FraudGraphNode_type_valueHash_key" ON "FraudGraphNode"("type", "valueHash");


-- CreateIndex
CREATE INDEX "FraudGraphEdge_fromId_relation_idx" ON "FraudGraphEdge"("fromId", "relation");


-- CreateIndex
CREATE INDEX "FraudGraphEdge_toId_relation_idx" ON "FraudGraphEdge"("toId", "relation");


-- CreateIndex
CREATE UNIQUE INDEX "DeviceRegistration_userId_deviceHash_key" ON "DeviceRegistration"("userId", "deviceHash");


-- CreateIndex
CREATE INDEX "CommunicationRoom_caseId_status_idx" ON "CommunicationRoom"("caseId", "status");


-- CreateIndex
CREATE UNIQUE INDEX "SafeguardingCase_reportId_key" ON "SafeguardingCase"("reportId");


-- CreateIndex
CREATE INDEX "SafeguardingCase_status_priority_createdAt_idx" ON "SafeguardingCase"("status", "priority", "createdAt");


-- CreateIndex
CREATE UNIQUE INDEX "PaymentProvider_countryCode_type_name_key" ON "PaymentProvider"("countryCode", "type", "name");


-- CreateIndex
CREATE INDEX "PaymentAttempt_transactionId_status_idx" ON "PaymentAttempt"("transactionId", "status");


-- CreateIndex
CREATE INDEX "ExchangeRateSnapshot_baseCurrency_quoteCurrency_capturedAt_idx" ON "ExchangeRateSnapshot"("baseCurrency", "quoteCurrency", "capturedAt");


-- CreateIndex
CREATE INDEX "Organization_countryCode_status_idx" ON "Organization"("countryCode", "status");


-- CreateIndex
CREATE INDEX "OrganizationMember_userId_status_idx" ON "OrganizationMember"("userId", "status");


-- CreateIndex
CREATE UNIQUE INDEX "OrganizationMember_organizationId_userId_key" ON "OrganizationMember"("organizationId", "userId");


-- CreateIndex
CREATE INDEX "HelpCircle_ownerId_status_idx" ON "HelpCircle"("ownerId", "status");


-- CreateIndex
CREATE UNIQUE INDEX "HelpCircleMember_circleId_userId_key" ON "HelpCircleMember"("circleId", "userId");


-- CreateIndex
CREATE INDEX "Appeal_status_createdAt_idx" ON "Appeal"("status", "createdAt");


-- CreateIndex
CREATE INDEX "Appeal_caseId_idx" ON "Appeal"("caseId");


-- CreateIndex
CREATE INDEX "Project_countryCode_status_idx" ON "Project"("countryCode", "status");


-- CreateIndex
CREATE INDEX "ProjectMilestone_projectId_status_idx" ON "ProjectMilestone"("projectId", "status");


-- CreateIndex
CREATE INDEX "PublicImpactSnapshot_countryCode_category_capturedAt_idx" ON "PublicImpactSnapshot"("countryCode", "category", "capturedAt");


-- CreateIndex
CREATE UNIQUE INDEX "CountryConfiguration_countryCode_key" ON "CountryConfiguration"("countryCode");


-- CreateIndex
CREATE INDEX "CountryConfiguration_enabled_idx" ON "CountryConfiguration"("enabled");


-- CreateIndex
CREATE INDEX "_ThreadParticipants_B_index" ON "_ThreadParticipants"("B");


-- AddForeignKey
ALTER TABLE "Referral" ADD CONSTRAINT "Referral_referrerId_fkey" FOREIGN KEY ("referrerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpCase" ADD CONSTRAINT "HelpCase_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpCase" ADD CONSTRAINT "HelpCase_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "CaseEvidence" ADD CONSTRAINT "CaseEvidence_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "VerificationRequest" ADD CONSTRAINT "VerificationRequest_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "VerificationRequest" ADD CONSTRAINT "VerificationRequest_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpOffer" ADD CONSTRAINT "HelpOffer_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "HelpOffer" ADD CONSTRAINT "HelpOffer_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "MessageThread" ADD CONSTRAINT "MessageThread_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_threadId_fkey" FOREIGN KEY ("threadId") REFERENCES "MessageThread"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;