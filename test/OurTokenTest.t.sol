// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

interface Mintable {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test, ZkSyncChainChecker {
    uint256 Bob_StartingAmount = 1000 ether;
    uint256 public constant initialSupply = 1000_000 ether;
    OurToken public ourToken;

    DeployOurToken public Deployer;
    address public DeployAddress;
    address Bob;
    address Alice;

    function setUp() public {
        Deployer = new DeployOurToken();
        if (!isZkSyncChain()) {
            ourToken = Deployer.run();
        } else {
            ourToken = new OurToken(initialSupply);
            ourToken.transfer(msg.sender, initialSupply);
        }

        Bob = makeAddr("Bob");
        Alice = makeAddr("Alice");
        vm.prank(msg.sender);
        ourToken.transfer(Bob, Bob_StartingAmount);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), Deployer.initialSupply());
    }

    function testUserCanMint() public {
        vm.expectRevert();
        Mintable(address(ourToken)).mint(address(this), 1);
    }

    function testAllowances() public {
        uint256 allowanceETH = 1000 ether;
        vm.prank(Bob);
        ourToken.approve(Alice, allowanceETH);

        vm.prank(Alice);
        uint256 halfAllowanceETH = 500 ether;
        ourToken.transferFrom(Bob, Alice, halfAllowanceETH);
        assertEq(ourToken.balanceOf(Bob), allowanceETH - halfAllowanceETH);
        assertEq(ourToken.balanceOf(Alice), halfAllowanceETH);
    }
}
