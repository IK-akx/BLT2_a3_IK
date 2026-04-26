import { BigInt } from "@graphprotocol/graph-ts";
import {
  Deposit as DepositEvent,
  Withdraw as WithdrawEvent,
  Harvest as HarvestEvent
} from "../generated/Vault/Vault";

import {
  Deposit,
  Withdrawal,
  Harvest,
  User,
  VaultStat
} from "../generated/schema";

function getUser(id: string): User {
  let user = User.load(id);

  if (user == null) {
    user = new User(id);
    user.totalDeposited = BigInt.zero();
    user.totalWithdrawn = BigInt.zero();
    user.depositCount = BigInt.zero();
    user.withdrawalCount = BigInt.zero();
  }

  return user as User;
}

function getVaultStat(): VaultStat {
  let stat = VaultStat.load("vault");

  if (stat == null) {
    stat = new VaultStat("vault");
    stat.totalDeposited = BigInt.zero();
    stat.totalWithdrawn = BigInt.zero();
    stat.totalHarvested = BigInt.zero();
    stat.depositCount = BigInt.zero();
    stat.withdrawalCount = BigInt.zero();
    stat.harvestCount = BigInt.zero();
  }

  return stat as VaultStat;
}

export function handleDeposit(event: DepositEvent): void {
  let id = event.transaction.hash.toHexString() + "-" + event.logIndex.toString();

  let deposit = new Deposit(id);
  deposit.caller = event.transaction.from;
  deposit.owner = event.transaction.from;
  deposit.assets = event.params.assets;
  deposit.shares = event.params.shares;
  deposit.blockNumber = event.block.number;
  deposit.timestamp = event.block.timestamp;
  deposit.transactionHash = event.transaction.hash;
  deposit.save();

  let user = getUser(event.params.owner.toHexString());
  user.totalDeposited = user.totalDeposited.plus(event.params.assets);
  user.depositCount = user.depositCount.plus(BigInt.fromI32(1));
  user.save();

  let stat = getVaultStat();
  stat.totalDeposited = stat.totalDeposited.plus(event.params.assets);
  stat.depositCount = stat.depositCount.plus(BigInt.fromI32(1));
  stat.save();
}

export function handleWithdraw(event: WithdrawEvent): void {
  let id = event.transaction.hash.toHexString() + "-" + event.logIndex.toString();

  let withdrawal = new Withdrawal(id);
  withdrawal.caller = event.transaction.from;
  withdrawal.receiver = event.transaction.from;
  withdrawal.owner = event.transaction.from;
  withdrawal.assets = event.params.assets;
  withdrawal.shares = event.params.shares;
  withdrawal.blockNumber = event.block.number;
  withdrawal.timestamp = event.block.timestamp;
  withdrawal.transactionHash = event.transaction.hash;
  withdrawal.save();

  let user = getUser(event.params.owner.toHexString());
  user.totalWithdrawn = user.totalWithdrawn.plus(event.params.assets);
  user.withdrawalCount = user.withdrawalCount.plus(BigInt.fromI32(1));
  user.save();

  let stat = getVaultStat();
  stat.totalWithdrawn = stat.totalWithdrawn.plus(event.params.assets);
  stat.withdrawalCount = stat.withdrawalCount.plus(BigInt.fromI32(1));
  stat.save();
}

export function handleHarvest(event: HarvestEvent): void {
  let id = event.transaction.hash.toHexString() + "-" + event.logIndex.toString();

  let harvest = new Harvest(id);
  harvest.amountAdded = event.params.amountAdded;
  harvest.blockNumber = event.block.number;
  harvest.timestamp = event.block.timestamp;
  harvest.transactionHash = event.transaction.hash;
  harvest.save();

  let stat = getVaultStat();
  stat.totalHarvested = stat.totalHarvested.plus(event.params.amountAdded);
  stat.harvestCount = stat.harvestCount.plus(BigInt.fromI32(1));
  stat.save();
}