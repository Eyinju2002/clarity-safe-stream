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
