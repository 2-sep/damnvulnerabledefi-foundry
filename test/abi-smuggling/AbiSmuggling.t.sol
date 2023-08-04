// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../Util.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SelfAuthorizedVault} from "../../src/abi-smuggling/SelfAuthorizedVault.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";

contract AbiSmugglingTest is Test{
  // 声明常量
  uint256 internal constant VAULT_TOKEN_BALANCE = 1_000_000e18;
  uint256 internal constant WITHDRAWAL_LIMIT = 1 ether;

  // Util 工具库
  Util internal util;

  // 声明合约对象
  DamnValuableToken public token;
  SelfAuthorizedVault public vault;

  // 声明地址变量
  address payable internal deployer;
  address payable internal player;
  address payable internal recovery;

  function setUp() public {
      // create user address 实例化
      util = new Util();
      address payable[] memory users = util.createUsers(3);
      deployer = users[0];
      player = users[1];
      recovery = users[2];

      // deploy token and vault contract 实例化
      token = new DamnValuableToken();
      vault = new SelfAuthorizedVault();

      assertNotEq(vault.getLastWithdrawalTimestamp(),0);
      
      // Set permissions
      bytes32[] memory Permission = new bytes32[](2);
      // sweepFunds(address,address)
      bytes32 deployerPermission = vault.getActionId(bytes4(0x85fb709d), deployer, address(vault));
      // withdraw(address,address,uint256)
      bytes32 playerPermission = vault.getActionId(bytes4(0xd9caed12),player,address(vault));
      Permission[0] = deployerPermission;
      Permission[1] = playerPermission;
      vault.setPermissions(Permission);

      assertTrue(vault.permissions(deployerPermission));
      assertTrue(vault.permissions(playerPermission));

      // Make sure Vault is initialized
      assertTrue(vault.initialized());

      // Deposit tokens into the vault
      token.transfer(address(vault), VAULT_TOKEN_BALANCE);

      // Cannot call Vault directly
      // vm.expectRevert("CallerNotAllowed()"); 这里怎么捕捉指定错误？
      vm.expectRevert();
      vault.sweepFunds(deployer, IERC20(address(token)));
      
      vm.expectRevert();
      vm.prank(player);
      vault.withdraw(address(token),player,WITHDRAWAL_LIMIT);

  }

  function testExploit() public{
      /**
       * EXPLOIT START *
       */
      vault.execute()
      /**
       * EXPLOIT END *
       */
      // validation()
  }
  
  function validation() internal{
    assertNotEq(token.balanceOf(address(vault)),0);
    assertNotEq(token.balanceOf(player),0);
    assertNotEq(token.balanceOf(recovery),VAULT_TOKEN_BALANCE);
  }
}