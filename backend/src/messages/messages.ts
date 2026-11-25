import {
  BadRequestException,
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  Post,
  Req,
} from '@nestjs/common';
import {
  IsInt,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { Request } from 'express';
import { PrismaService } from '../prisma.service';

export class SendMessageDto {
  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  body!: string;
}

export class StartCaseChatDto {
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  caseId!: string;

  @IsInt()
  @Min(1)
  @Max(2_000_000_000)
  offerAmountMinor!: number;
}

@Controller('messages')
export class MessagesController {
  constructor(private p: PrismaService) {}

  @Get('threads')
  async threads(@Req() r: Request) {
    const uid = (r as any).user.sub;
    const threads = await this.p.messageThread.findMany({
      where: { participants: { some: { id: uid } } },
      include: {
        case: {
          select: {
            id: true,
            title: true,
            category: true,
            goalMinor: true,
            currency: true,
            countryCode: true,
            city: true,
            ownerId: true,
            publicIdentityMode: true,
            publicDisplayName: true,
            owner: { select: { name: true, publicAlias: true, publicIdentityMode: true } },
          },
        },
        participants: {
          select: { id: true, name: true, publicAlias: true, publicIdentityMode: true },
        },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
          select: { body: true },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });
    return threads.map(({ case: request, participants, messages, ...thread }) => {
      const requestMode = request?.publicIdentityMode ?? request?.owner.publicIdentityMode;
      const requesterName = requestMode === 'ANONYMOUS'
        ? 'Anonymous member'
        : requestMode === 'ALIAS'
          ? request?.owner.publicAlias ?? 'Helpi member'
          : request?.publicDisplayName ?? request?.owner.name ?? 'Helpi member';
      return {
        ...thread,
        case: request ? {
          id: request.id,
          title: request.title,
          category: request.category,
          goalMinor: request.goalMinor,
          currency: request.currency,
          countryCode: request.countryCode,
          city: request.city,
        } : null,
        participants: participants.map(({ id, name, publicAlias, publicIdentityMode }) => ({
          id,
          name: request && id === request.ownerId
            ? requesterName
            : publicIdentityMode === 'ANONYMOUS'
              ? 'Anonymous member'
              : publicIdentityMode === 'ALIAS'
                ? publicAlias ?? 'Helpi member'
                : name,
        })),
        messages,
      };
    });
  }

  @Post('threads')
  async startCaseChat(@Req() r: Request, @Body() d: StartCaseChatDto) {
    const userId = (r as any).user.sub;
    const request = await this.p.helpCase.findUnique({
      where: { id: d.caseId },
      select: {
        id: true,
        ownerId: true,
        title: true,
        currency: true,
        status: true,
      },
    });
    if (!request || request.status !== 'PUBLISHED') {
      throw new ForbiddenException('This request is not available.');
    }
    if (request.ownerId === userId) {
      throw new BadRequestException('You cannot offer help on your own request.');
    }

    const existingThreads = await this.p.messageThread.findMany({
      where: {
        caseId: request.id,
        participants: { some: { id: request.ownerId } },
      },
      include: { participants: { select: { id: true } } },
    });
    let thread = existingThreads.find((candidate) =>
      candidate.participants.some((participant) => participant.id === userId),
    );

    if (!thread) {
      thread = await this.p.messageThread.create({
        data: {
          caseId: request.id,
          participants: {
            connect: [{ id: userId }, { id: request.ownerId }],
          },
        },
        include: { participants: { select: { id: true } } },
      });
    }

    const amount = (d.offerAmountMinor / 100).toFixed(2);
    const message = `I would like to offer ${request.currency} ${amount}. Let's connect to discuss details.`;
    await this.p.message.create({
      data: { threadId: thread.id, senderId: userId, body: message },
    });
    await this.p.messageThread.update({
      where: { id: thread.id },
      data: { updatedAt: new Date() },
    });

    return { id: thread.id, title: request.title };
  }

  @Get('threads/:id')
  async messages(@Req() r: Request, @Param('id') id: string) {
    const uid = (r as any).user.sub;
    const thread = await this.p.messageThread.findFirst({
      where: { id, participants: { some: { id: uid } } },
    });
    if (!thread) throw new ForbiddenException();
    return this.p.message.findMany({
      where: { threadId: id },
      orderBy: { createdAt: 'asc' },
      take: 200,
    });
  }

  @Post('threads/:id')
  async send(
    @Req() r: Request,
    @Param('id') id: string,
    @Body() d: SendMessageDto,
  ) {
    const uid = (r as any).user.sub;
    const thread = await this.p.messageThread.findFirst({
      where: { id, participants: { some: { id: uid } } },
    });
    if (!thread) throw new ForbiddenException();
    const message = await this.p.message.create({
      data: { threadId: id, senderId: uid, body: d.body },
    });
    await this.p.messageThread.update({
      where: { id },
      data: { updatedAt: new Date() },
    });
    return message;
  }
}
