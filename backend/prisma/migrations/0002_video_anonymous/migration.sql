-- Helpi v9: privacy-first public identity and video evidence
CREATE TYPE "PublicIdentityMode" AS ENUM ('REAL_NAME', 'ANONYMOUS', 'ALIAS');
CREATE TYPE "MediaModerationStatus" AS ENUM ('PENDING', 'SCANNING', 'APPROVED', 'REVIEW', 'BLOCKED');

ALTER TABLE "User"
  ADD COLUMN "publicIdentityMode" "PublicIdentityMode" NOT NULL DEFAULT 'REAL_NAME',
  ADD COLUMN "publicAlias" TEXT;

ALTER TABLE "HelpCase"
  ADD COLUMN "publicIdentityMode" "PublicIdentityMode" NOT NULL DEFAULT 'REAL_NAME',
  ADD COLUMN "publicDisplayName" TEXT;

ALTER TABLE "CaseEvidence"
  ADD COLUMN "durationSeconds" INTEGER,
  ADD COLUMN "thumbnailStorageKey" TEXT,
  ADD COLUMN "moderationStatus" "MediaModerationStatus" NOT NULL DEFAULT 'PENDING',
  ADD COLUMN "moderationReason" TEXT;

CREATE INDEX "CaseEvidence_moderationStatus_createdAt_idx" ON "CaseEvidence"("moderationStatus", "createdAt");
