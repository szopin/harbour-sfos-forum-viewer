import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Secrets 1.0 as Secrets
import Sailfish.Crypto 1.0 as Crypto
import Nemo.Configuration 1.0


Page {

        id: page

     property string pubkey
    property var payload
    property var plaintext: dr.plaintext


function dec(payload){
        payload = payload.replace(/(\r|\n)/gm, '');
        var myArray = base64DecToArr(payload);
        var myBuffer = base64DecToArr(payload).buffer;

    dr.data = myBuffer;
    dr.startRequest();
    }

    function b64ToUint6 (nChr) {
         return nChr > 64 && nChr < 91 ?
         nChr - 65
         : nChr > 96 && nChr < 123 ?
         nChr - 71
         : nChr > 47 && nChr < 58 ?
         nChr + 4
        : nChr === 43 ?
         62
        : nChr === 47 ?
         63
         :
        0;
         }
     function base64DecToArr (sBase64, nBlocksSize) {
        var
         sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""), nInLen = sB64Enc.length,
        nOutLen = nBlocksSize ? Math.ceil((nInLen * 3 + 1 >> 2) / nBlocksSize) * nBlocksSize : nInLen * 3 + 1 >> 2, taBytes = new Uint8Array(nOutLen);
         for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
             nMod4 = nInIdx & 3;
            nUint24 |= b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 6 * (3 - nMod4);
            if (nMod4 === 3 || nInLen - nInIdx === 1) {
                 for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
                     taBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
                     }
                 nUint24 = 0;
                 }
            }
        return taBytes;
        }

        ConfigurationGroup {
        id: mainConfig
        path: "/apps/harbour-sfos-forum-viewer"
    }
        Component.onCompleted: gkr.startRequest()

        Rectangle {
            id: rect
            anchors.fill: parent
            color: "lightsteelblue"

            Column {
                width: parent.width
                Text {
                    width: rect.width
                    height: rect.height / 3
                    text: pubkey
                    wrapMode: Text.Wrap
                }

            }
        }

        Crypto.CryptoManager {
            id: crypto
        }

        Crypto.GenerateKeyRequest {
            id: gkr
            manager: crypto
            cryptoPluginName: crypto.defaultCryptoPluginName
            keyTemplate: {
               var key = crypto.constructKey("myKey", "myGroup", crypto.defaultCryptoPluginName)
               key.algorithm = Crypto.CryptoManager.AlgorithmRsa
               key.operations = Crypto.CryptoManager.OperationEncrypt | Crypto.CryptoManager.OperationDecrypt
                return key
            }
            keyPairGenerationParameters: crypto.constructRsaKeygenParams({"modulusLength": 2048, "numberPrimes": 2, "publicExponent": 65537});
            onResultChanged: {
                if (result.code == Crypto.Result.Failed) {
                    console.log("GKR: error: " + result.errorMessage)
                } else if (result.code == Crypto.Result.Succeeded) {
                    console.log("GKR: succeeded")
                   pubkey = gkr.generatedKey.publicKey

                    console.log(pubkey)
                                        var dialog = pageStack.push("LoginWeb.qml", {pubkey: pubkey});
                }
}
}

        Crypto.DecryptRequest {
            id: dr
            manager: crypto
            cryptoPluginName: crypto.defaultCryptoPluginName
            key: gkr.generatedKey
             blockMode: Crypto.CryptoManager.BlockModeUnknown
            padding: Crypto.CryptoManager.EncryptionPaddingRsaPkcs1

            onResultChanged: {
                if (result.code == Crypto.Result.Failed) {
                    console.log("DR: error: " + result.errorMessage)
                } else if (result.code == Crypto.Result.Succeeded) {
                    console.log("DR: succeeded: have plaintext: " + dr.plaintext)
                var decode = JSON.parse(dr.plaintext);
                mainConfig.setValue("key", decode.key);
                pageStack.completeAnimation();
                pageStack.pop();
                }
            }
        }
    }

