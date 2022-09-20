'use strict';

// Tx Sentry - Send and listen to transactions form elm to web3 provider
export function txSentry(fromElm, toElm, web3) {
    checkFromElmPort(fromElm);
    checkToElmPort(toElm);
    checkWeb3(web3);

    fromElm.subscribe(function (txData) {
        try {
            web3.request({
              method: 'eth_sendTransaction',
              params: txData.txParams
            }).then(function (e, r) {
                toElm.send({ ref: txData.ref, txHash: r || e });
            });
        } catch (error) {
            console.log(error);
            toElm.send({ ref: txData.ref, txHash: null });
        }
    });
}

// Wallet Sentry - listen to account and network changes
export function walletSentry(toElm, web3) {
    checkToElmPort(toElm);
    checkWeb3(web3);
    var model = { account: null, networkId: 0 };
    getNetworkAndAccount(web3, sendModelToElm(toElm, model)) // Make initial call for data.
    setInterval(function () { getNetworkAndAccount(web3, sendModelToElm(toElm, model)) }, 500); // Repeat on half second interval.
}

// Helper function that calls out to web3 for account/network
function getNetworkAndAccount(web3, callback) {
    const networkId = web3.chainId;
    const account = web3.selectedAddress;
    callback( {account: account, networkId: parseInt(networkId)} );
}

// Updates model and sends to Elm if anything has changed. Curried to make callback easier.
function sendModelToElm(toElm, globalModel) {
    return function (newModel) {
        if (newModel.account !== globalModel.account || newModel.networkId !== globalModel.networkId) {
            globalModel = newModel;
            toElm.send(globalModel);
        }
    }
}

// Logging Helpers

function checkToElmPort(port) {
    if (typeof port === 'undefined' || typeof port.send === 'undefined') {
        console.warn('elm-ethereum-ports: The port to send messages to Elm is malformed.')
    }
}

function checkFromElmPort(port) {
    if (typeof port === 'undefined' || typeof port.subscribe === 'undefined') {
        console.warn('elm-ethereum-ports: The port to subscribe to messages from Elm is malformed.')
    }
}

function checkWeb3(web3) {
    if (typeof window.ethereum === 'undefined' && ethereum.isConnected()) {
        console.warn('elm-ethereum-ports: ethereum object is undefined, or ethereum.isConnected() is false')
    }
}