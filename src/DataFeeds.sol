// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./libraries/AggregatorV3Interface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED
 * VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/**
 * If you are reading data feeds on L2 networks, you must
 * check the latest answer from the L2 Sequencer Uptime
 * Feed to ensure that the data is accurate in the event
 * of an L2 sequencer outage. See the
 * https://docs.chain.link/data-feeds/l2-sequencer-feeds
 * page for details.
 */

//LINK/ETH 0x42585eD362B3f1BCa95c640FdFf35Ef899212734
//ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306

contract DataConsumerV3 {
    AggregatorV3Interface internal dataFeed;

        /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */
    mapping(uint256 => address) public dataFeedAddresses;

    constructor() {
        dataFeedAddresses[0] = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // ethToUsd
        dataFeedAddresses[1] = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43; // btcToUsd
        dataFeedAddresses[2] = 0xc59E3633BAAC79493d908e63626716e204A45EdF; // linkToUsd
        dataFeedAddresses[3] = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E; // usdcToUsd
        dataFeedAddresses[4] = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19; // daiToUsd
    }


    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer(uint256 dataFeedIndex) public view returns (int) {
        //El parametro dataFeedIndex indica el numero de address de las guardadas se va a usar para obtener los datos de cambio
        AggregatorV3Interface dataFeed2 = AggregatorV3Interface(dataFeedAddresses[dataFeedIndex]);

        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed2.latestRoundData();
        return answer;
    }
    /*
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            //uint80 roundID 
            ,
            int answer,
            //uint startedAt
            ,
            //uint timeStamp
            ,
            //uint80 answeredInRound

        ) = dataFeed.latestRoundData();
        return answer;
    }*/
}