# Stacks Pooled Cyber Insurance DAO Smart Contract

## Overview

This smart contract implements a decentralized autonomous organization (DAO) for managing a pooled cyber insurance fund on the Stacks blockchain. Members contribute to the insurance pool, submit claims in case of cyber incidents, and vote on the validity of claims to determine payouts.

The contract operates under democratic principles, ensuring that all decisions about fund disbursement are made collectively by pool members.

## Features

1. **Manual Block Height Tracking**
    - Maintains a custom block height for operations.
    - Prevents unauthorized or frequent updates by the same user.

2. **Insurance Pool Contributions**
    - Members can contribute to the insurance pool.
    - Contributions activate coverage for the contributor.

3. **Claim Submission**
    - Members can submit claims for reimbursement due to cyber incidents.
    - Claims are subject to voting by other members within a defined period.

4. **Voting Mechanism**
    - Members vote to approve or reject claims.
    - Voting is time-bound, and each member can vote only once per claim.

5. **Claim Payout Determination**
    - Claims are resolved based on voting results.
    - Approved claims are eligible for payouts from the pool.

## Contract Components

### Constants

- **CONTRACT-OWNER**: The creator of the contract.

### Error Codes

- **ERR-NOT-AUTHORIZED (u1)**: Unauthorized action.
- **ERR-INSUFFICIENT-FUNDS (u2)**: Insufficient contribution.
- **ERR-INVALID-CLAIM (u3)**: Invalid claim reference.
- **ERR-ALREADY-VOTED (u4)**: Duplicate vote attempt.
- **ERR-CLAIM-TIMEOUT (u5)**: Voting or claim submission timeout.
- **ERR-BLOCK-UPDATE-FAILED (u6)**: Block height update failed.

### Data Variables

- **current-block-height**: Tracks custom block height.
- **last-block-updater**: Last user to update the block height.
- **total-pool-funds**: Total funds in the insurance pool.
- **next-claim-id**: ID for the next claim submission.

### Data Maps

- **insurance-pool**: Tracks member contributions and coverage status.
  - **Key**: `{member: principal}`
  - **Value**: `{contributed-amount, active-coverage, contribution-block}`

- **claims**: Tracks claim submissions.
  - **Key**: `{claim-id: uint}`
  - **Value**: `{protocol, amount-requested, total-votes, approved-votes, is-resolved, claim-block, voting-end-block}`

- **member-votes**: Tracks votes by members on specific claims.
  - **Key**: `{member: principal, claim-id: uint}`
  - **Value**: `{voted}`

## Functions

### Public Functions

1. **update-block-height**
    - Updates the current-block-height by one unit.
    - Ensures only one update per block by a member.

2. **contribute (amount uint)**
    - Allows members to contribute STX to the insurance pool.
    - Activates coverage for the contributor.

3. **submit-claim (protocol principal, amount-requested uint)**
    - Submits a claim for insurance.
    - The claim must be within the coverage period.

4. **vote-on-claim (claim-id uint, approve bool)**
    - Allows members to vote on a claim.
    - Votes can either approve or reject the claim.

### Read-Only Functions

1. **get-current-block-height**
    - Returns the current block height.

### Constants

- **VOTING-PERIOD**: 144 blocks (~24 hours).
- **CLAIM-EXPIRATION**: 1440 blocks (~10 days).

## Usage Workflow

### Contribution

- Members contribute funds to activate coverage.

### Claim Submission

- Members submit claims in case of incidents.
- Claims are voted on by other members.

### Voting

- Members vote to approve or reject claims.
- Voting period is limited to 144 blocks.

### Claim Resolution

- Claims are resolved based on voting results.
- Payouts are made for approved claims.

## Error Handling

The contract uses predefined error codes for robust error handling. Ensure all function calls handle potential errors correctly.

## Deployment Notes

- **Owner Privileges**: Contract owner can perform administrative updates if required.
- **Gas Costs**: Ensure adequate STX balance for contributions and claim submissions.