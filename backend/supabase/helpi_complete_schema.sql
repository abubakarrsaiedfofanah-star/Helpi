-- Helpi Supabase bootstrap SQL
-- Generated from prisma/schema.prisma and data/countries.json.
-- Run once in the SQL Editor of a NEW Supabase project.
-- Do not run this over an existing Helpi database; use Prisma migrations for upgrades.
-- RLS is enabled on all application tables with no client policies. The NestJS API must
-- use the private Supabase Postgres connection as the database owner/service role.

BEGIN;

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('MEMBER', 'VERIFIER', 'ADMIN', 'ORGANIZATION');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('PENDING', 'ACTIVE', 'SUSPENDED', 'DISABLED');

-- CreateEnum
CREATE TYPE "CaseStatus" AS ENUM ('DRAFT', 'UNDER_REVIEW', 'PUBLISHED', 'PAUSED', 'COMPLETED', 'REJECTED');

-- CreateEnum
CREATE TYPE "CaseCategory" AS ENUM ('MEDICAL', 'FOOD', 'EDUCATION', 'HOUSING', 'WATER', 'DISABILITY', 'EMERGENCY', 'COMMUNITY', 'FAMILY', 'FARMING', 'ELDERLY', 'OTHER', 'HARDSHIP', 'JOBLESS', 'WIDOW', 'ORPHAN', 'WAR_VICTIM', 'WAR_SURVIVOR', 'DISPLACED_PERSON', 'SINGLE_PARENT', 'UNEMPLOYED', 'LOW_INCOME_FAMILY', 'CAREGIVER', 'CHRONIC_ILLNESS', 'HOMELESS', 'TRAFFICKING_SURVIVOR');

-- CreateEnum
CREATE TYPE "OfferType" AS ENUM ('MONEY', 'GOODS', 'SKILLS', 'TIME', 'TRANSPORT', 'ACCOMMODATION', 'SERVICES', 'OTHER');

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('PENDING', 'IN_REVIEW', 'VERIFIED', 'REJECTED', 'NEEDS_MORE_EVIDENCE');

-- CreateEnum
CREATE TYPE "ThreadStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('SECURITY', 'CASE', 'MESSAGE', 'VERIFICATION', 'PAYMENT', 'SYSTEM');

-- CreateEnum
CREATE TYPE "ReportType" AS ENUM ('FRAUD', 'HARASSMENT', 'SCAM', 'SAFEGUARDING', 'OTHER');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('CREATED', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "FraudSignalStatus" AS ENUM ('OPEN', 'REVIEWED', 'DISMISSED', 'CONFIRMED');

-- CreateEnum
CREATE TYPE "SecurityEventStatus" AS ENUM ('OPEN', 'REVIEWED', 'RESOLVED');

-- CreateEnum
CREATE TYPE "DocumentReviewStatus" AS ENUM ('PENDING', 'PROCESSING', 'PASSED', 'FAILED', 'NEEDS_REVIEW');

-- CreateEnum
CREATE TYPE "VerificationType" AS ENUM ('IDENTITY', 'NEED', 'INSTITUTION', 'PAYMENT_DESTINATION', 'ENHANCED');

-- CreateEnum
CREATE TYPE "SanctionsStatus" AS ENUM ('PENDING', 'CLEAR', 'MATCH', 'REVIEW_REQUIRED', 'FAILED');

-- CreateEnum
CREATE TYPE "SafeguardingStatus" AS ENUM ('OPEN', 'TRIAGED', 'INVESTIGATING', 'RESOLVED');

-- CreateEnum
CREATE TYPE "CommunicationType" AS ENUM ('VOICE', 'VIDEO');

-- CreateEnum
CREATE TYPE "PublicIdentityMode" AS ENUM ('REAL_NAME', 'ANONYMOUS', 'ALIAS');

-- CreateEnum
CREATE TYPE "MediaModerationStatus" AS ENUM ('PENDING', 'SCANNING', 'APPROVED', 'REVIEW', 'BLOCKED');

-- CreateEnum
CREATE TYPE "PaymentProviderType" AS ENUM ('MPESA', 'CARD', 'BANK_TRANSFER', 'OTHER');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "supportGroup" "CaseCategory",
    "publicIdentityMode" "PublicIdentityMode" NOT NULL DEFAULT 'REAL_NAME',
    "publicAlias" TEXT,
    "countryCode" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'MEMBER',
    "status" "UserStatus" NOT NULL DEFAULT 'PENDING',
    "emailVerifiedAt" TIMESTAMP(3),
    "mfaEnabled" BOOLEAN NOT NULL DEFAULT false,
    "mfaSecretEncrypted" TEXT,
    "failedLoginCount" INTEGER NOT NULL DEFAULT 0,
    "lockedUntil" TIMESTAMP(3),
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Referral" (
    "id" TEXT NOT NULL,
    "referrerId" TEXT NOT NULL,
    "personName" TEXT NOT NULL,
    "needSummary" TEXT NOT NULL,
    "safeContact" TEXT,
    "consentConfirmed" BOOLEAN NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING_CONTACT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Referral_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HelpCase" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "organizationId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" "CaseCategory" NOT NULL,
    "goalMinor" INTEGER NOT NULL,
    "currency" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "city" TEXT,
    "status" "CaseStatus" NOT NULL DEFAULT 'DRAFT',
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "verificationSummary" TEXT,
    "publicIdentityMode" "PublicIdentityMode" NOT NULL DEFAULT 'REAL_NAME',
    "publicDisplayName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HelpCase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CaseEvidence" (
    "id" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "storageKey" TEXT NOT NULL,
    "sha256" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "uploadedBy" TEXT NOT NULL,
    "durationSeconds" INTEGER,
    "thumbnailStorageKey" TEXT,
    "moderationStatus" "MediaModerationStatus" NOT NULL DEFAULT 'PENDING',
    "moderationReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CaseEvidence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VerificationRequest" (
    "id" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "requesterId" TEXT NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "reason" TEXT,
    "reviewerId" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "VerificationRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HelpOffer" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "caseId" TEXT,
    "type" "OfferType" NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "amountMinor" INTEGER,
    "currency" TEXT,
    "countryCode" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HelpOffer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MessageThread" (
    "id" TEXT NOT NULL,
    "caseId" TEXT,
    "status" "ThreadStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MessageThread_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Message" (
    "id" TEXT NOT NULL,
    "threadId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Message_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Report" (
    "id" TEXT NOT NULL,
    "reporterId" TEXT NOT NULL,
    "caseId" TEXT,
    "type" "ReportType" NOT NULL,
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Report_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "readAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshSession" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "deviceName" TEXT,
    "userAgent" TEXT,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "RefreshSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmailVerificationToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmailVerificationToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PasswordResetToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PasswordResetToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "action" TEXT NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SecurityEvent" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "type" TEXT NOT NULL,
    "severity" TEXT NOT NULL,
    "status" "SecurityEventStatus" NOT NULL DEFAULT 'OPEN',
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "deviceHash" TEXT,
    "details" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMP(3),
    "resolvedBy" TEXT,

    CONSTRAINT "SecurityEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PayoutDestination" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "countryCode" TEXT NOT NULL,
    "method" TEXT NOT NULL,
    "destinationHash" TEXT NOT NULL,
    "encryptedDestination" TEXT,
    "displayLast4" TEXT,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "riskLevel" TEXT NOT NULL DEFAULT 'LOW',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "verifiedAt" TIMESTAMP(3),
    "blockedAt" TIMESTAMP(3),

    CONSTRAINT "PayoutDestination_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PayoutApproval" (
    "id" TEXT NOT NULL,
    "destinationId" TEXT NOT NULL,
    "reviewerId" TEXT NOT NULL,
    "decision" TEXT NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PayoutApproval_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "amountMinor" INTEGER NOT NULL,
    "currency" TEXT NOT NULL,
    "purpose" TEXT,
    "status" "TransactionStatus" NOT NULL DEFAULT 'CREATED',
    "providerReference" TEXT,
    "idempotencyKey" TEXT,
    "blockedReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FraudSignal" (
    "id" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "actorId" TEXT,
    "type" TEXT NOT NULL,
    "severity" TEXT NOT NULL,
    "status" "FraudSignalStatus" NOT NULL DEFAULT 'OPEN',
    "details" JSONB,
    "resolutionNote" TEXT,
    "resolvedBy" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FraudSignal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentWebhookEvent" (
    "id" TEXT NOT NULL,
    "providerReference" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "payloadHash" TEXT NOT NULL,
    "processed" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),

    CONSTRAINT "PaymentWebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DocumentCheck" (
    "id" TEXT NOT NULL,
    "evidenceId" TEXT NOT NULL,
    "status" "DocumentReviewStatus" NOT NULL DEFAULT 'PENDING',
    "ocrTextEncrypted" TEXT,
    "extractedData" JSONB,
    "tamperSignals" JSONB,
    "providerReference" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DocumentCheck_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "IdentityVerification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "VerificationType" NOT NULL,
    "provider" TEXT NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "providerReference" TEXT,
    "countryCode" TEXT NOT NULL,
    "documentType" TEXT,
    "documentLast4" TEXT,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "IdentityVerification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InstitutionVerification" (
    "id" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "institutionName" TEXT NOT NULL,
    "institutionType" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "status" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "providerReference" TEXT,
    "evidence" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "InstitutionVerification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SanctionsScreening" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "caseId" TEXT,
    "provider" TEXT NOT NULL,
    "status" "SanctionsStatus" NOT NULL DEFAULT 'PENDING',
    "providerReference" TEXT,
    "result" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SanctionsScreening_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FraudGraphNode" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "valueHash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FraudGraphNode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FraudGraphEdge" (
    "id" TEXT NOT NULL,
    "fromId" TEXT NOT NULL,
    "toId" TEXT NOT NULL,
    "relation" TEXT NOT NULL,
    "confidence" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FraudGraphEdge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DeviceRegistration" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "deviceHash" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "pushToken" TEXT,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DeviceRegistration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CommunicationRoom" (
    "id" TEXT NOT NULL,
    "type" "CommunicationType" NOT NULL,
    "provider" TEXT NOT NULL,
    "providerRoomId" TEXT,
    "caseId" TEXT,
    "createdById" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" TIMESTAMP(3),

    CONSTRAINT "CommunicationRoom_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SafeguardingCase" (
    "id" TEXT NOT NULL,
    "reportId" TEXT NOT NULL,
    "status" "SafeguardingStatus" NOT NULL DEFAULT 'OPEN',
    "priority" TEXT NOT NULL DEFAULT 'NORMAL',
    "assignedToId" TEXT,
    "actionPlan" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SafeguardingCase_pkey" PRIMARY KEY ("id")
);

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
