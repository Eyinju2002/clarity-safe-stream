import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure users cannot vote twice on same claim",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        
        let block = chain.mineBlock([
            Tx.contractCall(
              "governance",
              "vote-on-claim",
              [types.uint(1), types.bool(true)],
              deployer.address
            )
        ]);
        assertEquals(block.receipts[0].result, '(ok true)');
        
        block = chain.mineBlock([
            Tx.contractCall(
              "governance",
              "vote-on-claim", 
              [types.uint(1), types.bool(true)],
              deployer.address
            )
        ]);
        assertEquals(block.receipts[0].result, '(err u404)');
    },
});

Clarinet.test({
    name: "Test claim finalization",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const voter1 = accounts.get("wallet_1")!;
        const voter2 = accounts.get("wallet_2")!;
        const voter3 = accounts.get("wallet_3")!;
        
        // Submit votes
        let block = chain.mineBlock([
            Tx.contractCall(
              "governance",
              "vote-on-claim",
              [types.uint(1), types.bool(true)],
              voter1.address
            ),
            Tx.contractCall(
              "governance",
              "vote-on-claim",
              [types.uint(1), types.bool(true)],
              voter2.address
            ),
            Tx.contractCall(
              "governance",
              "vote-on-claim",
              [types.uint(1), types.bool(false)],
              voter3.address
            )
        ]);
        
        // Advance blocks
        chain.mineEmptyBlockUntil(chain.blockHeight + 145);
        
        // Finalize claim
        block = chain.mineBlock([
            Tx.contractCall(
              "governance",
              "finalize-claim",
              [types.uint(1)],
              deployer.address
            )
        ]);
        assertEquals(block.receipts[0].result, '(ok true)');
    },
});
