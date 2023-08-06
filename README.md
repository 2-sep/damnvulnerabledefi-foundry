**1_unstoppable**

目标：让金库停止闪电贷款

import 合约:

​ solmate/utils/FixedPointMathLib.sol 数学库

​ solmate/utils/ReentrancyGuard.sol 防重入攻击库

​ { SafeTransferLib, ERC4626, ERC20 } from "solmate/mixins/ERC4626.sol" 安全转账，**ERC4626 代币金库话**，ERC20

​ solmate/auth/Owned.sol 权限控制

​ openzeppelin-contracts/contracts/interfaces/IERC3156.sol

​ **ERC3156**

思路：**闪电贷** UnstoppableVault.flashLoan 的 flashLoan()中，if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();

**2_Naive receiver**

目标：清空接收者合约中的 eth

import 合约：solady/src/utils/SafeTransferLib.sol 安全转账库，内联汇编省 gas

思路：**闪电贷** LenderPool 合约中 flashLoan()没有对调用者进行限制，越权调用。

**3_Truster**

目标：取出池中的所有代币

import 合约：openzeppelin-contracts/contracts/utils/Address.sol 地址库

思路：**闪电贷** **call 注入攻击**

TrusterLenderPool 的 flashLoan 方法，没有对 target 校验。利用 functionCall 进行代币授权 approve。

目标合约地址.call{value:发送数额, gas:gas 数额}(字节码);

​ abi.encodeWithSignature("函数签名", 逗号分隔的具体参数)

**4_Side Entrance**

目标：取出池子中所有的 ETH

思路：**闪电贷 余额检查**

实现 IFlashLoanEtherReceiver 的恶意 excute(),通过向池子存入代币，仍然满足检查。

**5_The Rewarder**

目标：获取池子分红

import 合约：openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol

思路：**闪电贷 ERC20 快照**

**6_Selfie**

目标：取走借贷池中的全部代币

import: ISimpleGovernance.sol 治理代币合约

思路：**闪电贷 治理攻击**

提交提案、治理合约

**7_Compromised**

目标：掏空交易所

思路：**预言机操控**

控制预言机，进行低买高卖

**8_Puppet**

目标：取出借贷池中的所有代币

思路：**操控 DEX 价格预言机**

砸盘代币，去借贷池借钱

扩展：erc20-permit
