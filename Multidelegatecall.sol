//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract MultiDelegatecall{

    error DelegateCallFailed();

    function multiDelegatecall( bytes[] calldata data) external 
    payable 
    returns (bytes[] memory results)
    {
// Same size as the data 
        results = new bytes[](data.length);

// Traversing the array of data and delegatecall 
        for ( uint i = 0; i < data.length; i++){
           (bool ok, bytes memory res) =  address(this).delegatecall(data[i]);
           if (!ok){
               revert DelegateCallFailed();
           }
        }
    }
}
// Bob -> multi call --call  --> test (msg.sender = multi call)
// Bob -> test..delegatecall ---> test (msg.sender == Bob)


// Testing contracts for delegatecalls. Using is for inherance
contract TestingMultiDelegatecall is MultiDelegatecall{

    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit Log (msg.sender,"func1",x+y);
    }

    function func2() external returns (uint){
        emit Log(msg.sender,"func2",2);
        return 111;
    }


    
}


// Helper function to encode the functions with the parameters. 
contract Helper {

    function getFunc1Data(uint x, uint y) external pure returns (bytes memory){

        return abi.encodeWithSelector(TestingMultiDelegatecall.func1.selector,x,y);
    }

    function getFunc2Data() external pure returns(bytes memory){

        return abi.encodeWithSelector(TestingMultiDelegatecall.func2.selector);
    }
}