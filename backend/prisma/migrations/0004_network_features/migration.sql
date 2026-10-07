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
CREATE TABLE "OrganizationMember" (
  "id" TEXT NOT NULL,
  "organizationId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "role" TEXT NOT NULL DEFAULT 'STAFF',
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "OrganizationMember_pkey" PRIMARY KEY ("id")
);
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
CREATE TABLE "HelpCircleMember" (
  "id" TEXT NOT NULL,
  "circleId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "role" TEXT NOT NULL DEFAULT 'MEMBER',
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "HelpCircleMember_pkey" PRIMARY KEY ("id")
);
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
CREATE UNIQUE INDEX "OrganizationMember_organizationId_userId_key" ON "OrganizationMember"("organizationId","userId");
CREATE UNIQUE INDEX "HelpCircleMember_circleId_userId_key" ON "HelpCircleMember"("circleId","userId");
CREATE INDEX "Organization_countryCode_status_idx" ON "Organization"("countryCode","status");
CREATE INDEX "OrganizationMember_userId_status_idx" ON "OrganizationMember"("userId","status");
CREATE INDEX "HelpCircle_ownerId_status_idx" ON "HelpCircle"("ownerId","status");
CREATE INDEX "Appeal_status_createdAt_idx" ON "Appeal"("status","createdAt");
CREATE INDEX "Appeal_caseId_idx" ON "Appeal"("caseId");
CREATE INDEX "Project_countryCode_status_idx" ON "Project"("countryCode","status");
CREATE INDEX "ProjectMilestone_projectId_status_idx" ON "ProjectMilestone"("projectId","status");
CREATE INDEX "PublicImpactSnapshot_countryCode_category_capturedAt_idx" ON "PublicImpactSnapshot"("countryCode","category","capturedAt");
ALTER TABLE "OrganizationMember" ADD CONSTRAINT "OrganizationMember_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "OrganizationMember" ADD CONSTRAINT "OrganizationMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "HelpCircle" ADD CONSTRAINT "HelpCircle_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "HelpCircleMember" ADD CONSTRAINT "HelpCircleMember_circleId_fkey" FOREIGN KEY ("circleId") REFERENCES "HelpCircle"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "HelpCircleMember" ADD CONSTRAINT "HelpCircleMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Appeal" ADD CONSTRAINT "Appeal_caseId_fkey" FOREIGN KEY ("caseId") REFERENCES "HelpCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Appeal" ADD CONSTRAINT "Appeal_appellantId_fkey" FOREIGN KEY ("appellantId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Project" ADD CONSTRAINT "Project_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ProjectMilestone" ADD CONSTRAINT "ProjectMilestone_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "HelpCase" ADD COLUMN "organizationId" TEXT;
CREATE INDEX "HelpCase_organizationId_idx" ON "HelpCase"("organizationId");
ALTER TABLE "HelpCase" ADD CONSTRAINT "HelpCase_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;
