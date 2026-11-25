import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { CaseStatus, UserRole, UserStatus } from '@prisma/client';
import { IsIn } from 'class-validator';
import { Request } from 'express';

import { JwtAuthGuard } from '../auth/jwt.guard';
import { Roles } from '../roles.decorator';
import { AdminService } from './admin.service';

class UserStatusDto {
  @IsIn([UserStatus.ACTIVE, UserStatus.SUSPENDED, UserStatus.DISABLED])
  status!: UserStatus;
}

class ReportStatusDto {
  @IsIn(['IN_REVIEW', 'RESOLVED', 'DISMISSED'])
  status!: 'IN_REVIEW' | 'RESOLVED' | 'DISMISSED';
}

class RequestStatusDto {
  @IsIn([CaseStatus.PUBLISHED, CaseStatus.PAUSED])
  status!: 'PUBLISHED' | 'PAUSED';
}

@Controller('admin')
@UseGuards(JwtAuthGuard)
@Roles(UserRole.ADMIN)
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Get('dashboard')
  dashboard() {
    return this.admin.dashboard();
  }

  @Get('users')
  users(
    @Query('q') search = '',
    @Query('status') status?: UserStatus,
    @Query('page') page = '1',
    @Query('pageSize') pageSize = '25',
  ) {
    const validStatus = status && Object.values(UserStatus).includes(status)
      ? status
      : undefined;
    return this.admin.users(search, validStatus, Number(page) || 1, Number(pageSize) || 25);
  }

  @Patch('users/:id/status')
  updateUserStatus(
    @Req() request: Request,
    @Param('id') id: string,
    @Body() body: UserStatusDto,
  ) {
    const actor = (request as any).user;
    return this.admin.setUserStatus(
      actor.sub,
      id,
      body.status,
      request.ip,
      request.headers['user-agent']?.toString(),
    );
  }

  @Get('requests')
  requests() {
    return this.admin.requests();
  }

  @Patch('requests/:id/status')
  updateRequestStatus(
    @Req() request: Request,
    @Param('id') id: string,
    @Body() body: RequestStatusDto,
  ) {
    const actor = (request as any).user;
    return this.admin.updateRequestStatus(
      actor.sub,
      id,
      body.status,
      request.ip,
      request.headers['user-agent']?.toString(),
    );
  }

  @Get('organizations')
  organizations() {
    return this.admin.organizations();
  }

  @Get('safety-reports')
  safetyReports() {
    return this.admin.safetyReports();
  }

  @Patch('safety-reports/:id/status')
  updateReportStatus(
    @Req() request: Request,
    @Param('id') id: string,
    @Body() body: ReportStatusDto,
  ) {
    const actor = (request as any).user;
    return this.admin.updateReportStatus(
      actor.sub,
      id,
      body.status,
      request.ip,
      request.headers['user-agent']?.toString(),
    );
  }

  @Get('audit')
  audit() {
    return this.admin.audit();
  }
}
