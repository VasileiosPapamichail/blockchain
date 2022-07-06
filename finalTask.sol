pragma solidity ^0.5.9;

contract Task3 {

    struct Item {
        uint itemId;
        string itemType;
        address[] bidders;
        uint totalTickets;
    }

    Item [3] public items;
    address [3] public winners;
    uint bidderCount = 0; // πόσοι έχουν ποντάρει στο κάθε αντικείμενο
    address beneficiary;
    uint winningItem;

    constructor() public payable {
        beneficiary = msg.sender;
        // αρχικοποίηση των αντικειμένων
        address[] memory emptyArray;
        items[0] = Item({itemId:0, itemType:"Car", bidders:emptyArray, totalTickets:0});
        items[1] = Item({itemId:1, itemType:"Phone", bidders:emptyArray, totalTickets:0});
        items[2] = Item({itemId:2, itemType:"Computer", bidders:emptyArray, totalTickets:0});
        
        winners[0] = address(0);
        winners[1] = address(0);
        winners[2] = address(0);
    }

    function bid(uint _itemId) public payable bidModifier(_itemId) notOwner {
        require(msg.value == .01 ether);
        items[_itemId].bidders[bidderCount] = msg.sender;
        items[_itemId].totalTickets++;
        bidderCount++;
    }

    function declareWinner(uint _itemId) public onlyOwner {
        uint rand;

        if (items[_itemId].totalTickets > 0) {
            rand = random(items[_itemId].totalTickets);
            winners[_itemId] = items[_itemId].bidders[rand];
        } else {
            revert();
        }
    }

    function random(uint num) public view returns(uint) { 
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % num;
    }

    function reveal(uint _itemId) public view returns(uint) {
        return items[_itemId].totalTickets;
    }

    function amIWinner() public notOwner returns(bool) {
        bool flag;

        for (uint i=0; i<3; i++) {
            if (winners[i] == msg.sender) {
                flag = true;
                winningItem = i;
            } else {
                flag = false;
            }
        }
        return flag;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function destroyContract() public payable onlyOwner {
        selfdestruct(msg.sender);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        beneficiary = newOwner;
    }

    function reset() public onlyOwner {
        delete items;
        delete winners;
    }

    modifier bidModifier(uint ID) {
        require (winners[ID] == address(0));
        _;
    }

    modifier notOwner() {
		if (msg.sender == beneficiary || msg.sender == 0x153dfef4355E823dCB0FCc76Efe942BefCa86477) {
			revert();
		}
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != beneficiary || msg.sender != 0x153dfef4355E823dCB0FCc76Efe942BefCa86477) {
			revert();
		}
        _;
    }

}