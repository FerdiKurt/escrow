const { expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const Escrow = artifacts.require('EscrowContract');

function toBN(arg) {
    return web3.utils.toBN(arg)
}

function toWEI(arg) {
    return web3.utils.toWei(arg)
}

contract('Escrow Plan', (accounts) => {
    let escrow;
    const [lawyer, payer, recipient] = accounts

    const escrowId = 12345
    const nonExistingEscrowPlan = 666
    const planName = 'Escrow Plan 1'
    const requiredAmount = toWEI('2', 'ether')
    const invalidAmount = toWEI('1', 'ether')

    before(async () => {
        escrow = await Escrow.deployed();
    });

    it('should NOT add escrow plan if not lawyer ', async () => {
        await expectRevert(
            escrow.addEscrowPlan(
                planName,
                payer,
                recipient,
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
            recipient,
            requiredAmount,
            escrowId,
            { from: lawyer }
        )

        await expectEvent(tx, 'EscrowPlanCreated', {
            _planName: planName,
            _payer: payer,
            _recipient: recipient,
            _id: toBN(escrowId)
        })
    });
    it('should NOT add escrow plan if already exists ', async () => {
        await expectRevert(
            escrow.addEscrowPlan(
                planName,
                payer,
                recipient,
                requiredAmount,
                escrowId,
                { from: lawyer }
            ),
            'Existing Escrow!'
        )
    });

    it('should NOT deposit ether for non existing escrow plan', async () => {
        await expectRevert(
            escrow.depositEther(
                nonExistingEscrowPlan,
                { from: payer }
            ),
            'Non-existing Escrow!'
        )
    })
    it('should NOT deposit ether if not payer', async () => {
        await expectRevert(
            escrow.depositEther(
                escrowId,
                { from: recipient }
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
            { from: payer, value: requiredAmount}
        )

        await expectEvent(tx, 'EtherDeposited', { 
            _id: toBN(escrowId),
            _payer: payer,
            _etherAmount: toBN(requiredAmount)
        })
    })
    it('should NOT deposit ether if not pending transaction', async () => {
        await expectRevert(
            escrow.depositEther(
                escrowId,
                { from: payer, value: requiredAmount }
            ),
            'Only PENDING transactions!'
        )
    })

    it('should NOT withdraw ether if not lawyer', async () => {
        await expectRevert(
            escrow.withdrawEther(
                escrowId,
                { from: recipient }
            ),
            'Only Lawyer!'
        )
    });
    it('should NOT withdraw ether if not active transaction', async () => {
        await escrow.addEscrowPlan(
            planName,
            payer,
            recipient,
            requiredAmount,
            100,
            { from: lawyer }
        )

        await expectRevert(
            escrow.withdrawEther(
                100,
                { from: lawyer }
            ),
            'Only ACTIVE transactions!'
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
            _id: toBN(escrowId),
            _recipient: recipient,
            _receivedAmount: toWEI('2', 'ether')
        })

        const balanceAfter = await escrow.contractBalance()
        assert(balanceAfter == 0)
    })

});

