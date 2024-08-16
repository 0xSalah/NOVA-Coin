//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract SuperNovaToken {
    string public name = "SuperNovaToken";
    string public symbol = "NOVA";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;

    uint public constant A = 1e18;
    uint public reserveBalance;

    event Mint(address indexed to, uint amount, uint cost);
    event Burn(address indexed from, uint amount, uint refund);

    function priceToMint(uint amount) internal view returns (uint) {
        uint newSupply = totalSupply + amount;
        return A * (sqrt(newSupply) - sqrt(totalSupply));//error
    }

    function mint(uint amount) public payable {
        uint cost = priceToMint(amount);
        require(msg.value >= cost, "Insufficient ETH to mint token");

        balanceOf[msg.sender] += amount;
        totalSupply += amount;

        //return the excess amount
        uint excess = msg.value - cost;
        if(excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        reserveBalance += cost;

        emit Mint(msg.sender, amount, cost);
    }

    function priceToBurn(uint amount) internal view returns(uint){
        uint newSupply = totalSupply - amount;
        return A * (sqrt(totalSupply) - sqrt(newSupply));
    }

    function burn(uint amount) public {
        require(balanceOf[msg.sender] >= amount, "error");

        uint refund = priceToBurn(amount);
        require(reserveBalance >= refund, "error");

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        reserveBalance -= refund;

        payable(msg.sender).transfer(refund);

        emit Burn(msg.sender, amount, refund);

    }

    function currentPrice() public view returns(uint) {
        if (totalSupply == 0) {
            return A;
        }
        return A / sqrt(totalSupply);
    }


    //helper func to caluc the squard root
    function sqrt(uint x)internal pure returns(uint){
        if(x == 0) return 0;
        uint z = (x + 1) / 2;
        uint y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}