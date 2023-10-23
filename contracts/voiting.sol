// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Voting {
    using Counters for Counters.Counter;
    Counters.Counter private _participantCode;
    Counters.Counter private _VoterCode;
    address private owner;
    uint256 private votingtime = 10;
    uint256 private startedTime;

    constructor() {
        owner = msg.sender;
        startedTime = ((((block.timestamp / 1000) / 60) / 60 / 24));
    }

    mapping(uint256 => Participantinfo) public Participants;
    mapping(address => Voterinfo) public Voters;

    modifier Onlyowner() {
        require(msg.sender == owner, "you not the owner of this contract");
        _;
    }

    modifier CheckVotingTime() {
        require(
            ((((block.timestamp / 1000) / 60) / 60) / 24) - startedTime <
                votingtime,
            "voting time is over"
        );
        _;
    }

    struct Voterinfo {
        uint256 voteregistrationdate;
        uint256 votecode;
        uint256 voterCode;
    }

    struct Participantinfo {
        string name;
        uint256 participantcode;
        address participantAddress;
        uint256 numbervotes;
    }

    function AddParticipant(string memory participantName) public {
        _participantCode.increment();
        uint256 participantCode = _participantCode.current();
        Participants[participantCode] = Participantinfo(
            participantName,
            participantCode,
            msg.sender,
            0
        );
    }

    function ParticipantList() public view returns (Participantinfo[] memory) {
        participantNumber = _participantCode.current();
        uint256 index = 0;
        Participantinfo[] memory participantList = new Participantinfo[]();

        for (uint256 i = 0; i < participantNumber; i++) {
            Participantinfo memory currentParticipant = Participants[i + 1];
            participantList[index] = currentParticipant;
            index++;
        }
        return participantList;
    }

    function RemoveParticipant(uint256 participantcode) public Onlyowner {
        delete Participants[participantcode];
    }

    function voting(uint256 participantcode) public CheckVotingTime {
        _VoterCode.increment();
        uint votercode = _VoterCode.current();
        Voters[msg.sender] = Voterinfo(
            block.timestamp,
            participantcode,
            votercode
        );
    }

    function UpdateVote(uint256 newParticipantCode) public CheckVotingTime {
        Voters[msg.sender].votecode = newParticipantCode;
        Voters[msg.sender].voteregistrationdate = block.timestamp;
    }

    function RemoveVote() public CheckVotingTime {
        delete Voters[msg.sender];
    }

    function CountingVotes()
        public
        view
        Onlyowner
        returns (Participantinfo[] memory)
    {
        require(
            ((((block.timestamp / 1000) / 60) / 60) / 24) - startedTime >
                votingtime,
            "voting time is not over yet"
        );
        uint256 numberOfVotrs = _VoterCode.current();
        uint256 participants = _participantCode.current();
        Participantinfo[] memory participantsInfo = new Participantinfo[](
            participants
        );

        for (uint i = 0; i < numberOfVotrs; i++) {
            uint256 vote = Voters[i + 1].votecode;
            Participants[vote].numbervotes++;
        }

        for (uint i = 0; i < participantsInfo.length; i++) {
            participantsInfo[i] = Participants[i + 1];
        }

        return participantsInfo;
    }
}
