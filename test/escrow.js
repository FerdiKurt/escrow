const { expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const Escrow = artifacts.require('Escrow');

function toBN(arg) {
    return web3.utils.toBN(arg)
}

function toWEI(arg) {
    return web3.utils.toWei(arg)
}

contract('Escrow Plan', (accounts) => {
    let escrow;
    const [lawyer, payer, receiver] = accounts

    const escrowId = '0x7dd304bc2f6b14047aa5455a5fa686db1f93879e8eac5e1209a81261fbf3af4c'
    const nonExistingEscrowPlanId = '0x7dd304bc2f6b14047aa5455a5fa686db1f93879e8eac5e1209a81261fbf3af4f'
    const planName = 'Escrow Plan 1'
    const requiredAmount = toWEI('2', 'ether')
    const invalidAmount = toWEI('1', 'ether')

    before(async () => {
        escrow = await Escrow.new();
    });

    it('should NOT add escrow plan if not lawyer ', async () => {
        // console.log(payer)
        // console.log(receiver)
        await expectRevert(
            escrow.addEscrowPlan(
                planName,
                payer,
                receiver,
                requiredAmount,
                escrowId,
                { from: payer }
            ),
            'Only Lawyer!'
        )
    });
    it('should ADD escrow plan', async () => {
        const tx = await escrow.addEscrowPlan(
            planName,
            payer,
            receiver,
            requiredAmount,
            escrowId,
            { from: lawyer }
        )

        await expectEvent(tx, 'EscrowPlanCreated', {
            escrowPlanName: planName,
            escrowId,
            payer,
            receiver,
            requiredAmount,
            state: toBN(1)
        })
    });
    it('should NOT add escrow plan if already exists ', async () => {
        await expectRevert(
            escrow.addEscrowPlan(
                planName,
                payer,
                receiver,
                requiredAmount,
                escrowId,
                { from: lawyer }
            ),
            'Invalid State!'
        )
    });

    it('should NOT deposit ether for non existing escrow plan', async () => {
        await expectRevert(
            escrow.depositEther(
                nonExistingEscrowPlanId,
                { from: payer }
            ),
            'Invalid State!'
        )
    })
    it('should NOT deposit ether if not payer', async () => {
        await expectRevert(
            escrow.depositEther(
                escrowId,
                { from: receiver }
            ),
            "Only payer!"
        )
    })
    it('should NOT deposit ether more below the required amount', async () => {
        await expectRevert(
            escrow.depositEther(
                escrowId,
                { from: payer, value: invalidAmount }
            ),
            'Invalid amount provided!'
        )
    })
    it('should DEPOSIT ether', async () => {
        const tx = await escrow.depositEther(
            escrowId,
            { from: payer, value: requiredAmount }
        )

        await expectEvent(tx, 'EtherDeposited', { 
            escrowId,
            payer,
            etherAmount: requiredAmount,
            state: toBN(2)
        })
    })
    it('should NOT deposit ether if not pending transaction', async () => {
        await expectRevert(
            escrow.depositEther(
                escrowId,
                { from: payer, value: requiredAmount }
            ),
            'Invalid State!'
        )
    })

    it('should NOT withdraw ether if not lawyer', async () => {
        await expectRevert(
            escrow.withdrawEther(
                escrowId,
                { from: receiver }
            ),
            'Only Lawyer!'
        )
    });
    it('should NOT withdraw ether if not active transaction', async () => {
        await escrow.addEscrowPlan(
            planName,
            payer,
            receiver,
            requiredAmount,
            nonExistingEscrowPlanId,
            { from: lawyer }
        )

        await expectRevert(
            escrow.withdrawEther(
                nonExistingEscrowPlanId,
                { from: lawyer }
            ),
            'Invalid State!'
        )
        
    });
    it('should WITHDRAW ether', async () => {
        const balanceBefore = await escrow.contractBalance()
        assert(balanceBefore == (toWEI('2', 'ether')))

        const tx = await escrow.withdrawEther(
            escrowId,
            { from: lawyer }
        )

        await expectEvent(tx, 'EtherWithdrawed', {
            escrowId,
            receiver,
            receivedAmount: requiredAmount,
            state: toBN(3)
        })

        const balanceAfter = await escrow.contractBalance()
        assert(balanceAfter == 0)
    })
});

