# SafeStream

A decentralized insurance protocol for streaming income built on Stacks.

## Overview
SafeStream allows users to protect their streaming income by creating insurance pools. Users can:
- Create insurance pools with customized parameters
- Join existing pools as insurers by staking STX
- Submit claims when they experience income loss 
- Vote on claims as pool participants

## Contracts
- `safe-stream.clar`: Main protocol contract handling pools and claims
- `governance.clar`: Handles voting and claim approvals, with duplicate vote prevention
- `staking.clar`: Manages staking and rewards for insurers

## Usage
[Documentation on contract usage and examples]

## Recent Updates
- Added prevention of duplicate votes on claims to ensure voting integrity
- Each user can only vote once per claim
- Attempts to vote multiple times will return error 404
