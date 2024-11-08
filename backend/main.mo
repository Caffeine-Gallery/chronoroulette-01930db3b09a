import Bool "mo:base/Bool";

import Timer "mo:base/Timer";
import Random "mo:base/Random";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Time "mo:base/Time";

actor {
    type Crystal = {
        id: Nat;
        size: Float;
        color: Text;
        pattern: Nat;
        growing: Bool;
    };

    stable var nextId : Nat = 0;
    stable var crystals : [(Nat, Crystal)] = [];
    
    private var timers = Buffer.Buffer<Timer.TimerId>(0);
    private var entropy : Nat = 0;

    public func createCrystal() : async Nat {
        let seed = await Random.blob();
        let random = Random.Finite(seed);
        
        let randomColor = switch (random.byte()) {
            case null "#4A90E2";
            case (?b) {
                let hue = Float.fromInt(Int.fromNat(Nat8.toNat(b))) * 360.0 / 255.0;
                "hsl(" # Float.toText(hue) # ", 70%, 60%)";
            };
        };

        let randomPattern = switch (random.byte()) {
            case null 1;
            case (?b) (Nat8.toNat(b) % 5) + 1;
        };

        let crystal : Crystal = {
            id = nextId;
            size = 1.0;
            color = randomColor;
            pattern = randomPattern;
            growing = true;
        };

        crystals := Array.append(crystals, [(nextId, crystal)]);
        
        let timerId = Timer.setTimer(#seconds 1, func() : async () {
            if (getCrystal(nextId).growing and getCrystal(nextId).size < 100.0) {
                crystals := await updateCrystalGrowth(nextId);
                // Schedule next growth if still growing
                if (getCrystal(nextId).growing and getCrystal(nextId).size < 100.0) {
                    let newTimerId = Timer.setTimer(#seconds 1, func() : async () {
                        await growCrystal(nextId);
                    });
                    timers.add(newTimerId);
                };
            };
        });
        timers.add(timerId);
        
        nextId += 1;
        nextId - 1;
    };

    private func updateCrystalGrowth(id: Nat) : async [(Nat, Crystal)] {
        let seed = await Random.blob();
        let random = Random.Finite(seed);
        
        Array.map<(Nat, Crystal), (Nat, Crystal)>(
            crystals,
            func((k, v)) : (Nat, Crystal) {
                if (k == id and v.growing and v.size < 100.0) {
                    let growthRate = switch (random.byte()) {
                        case null 1.0;
                        case (?b) Float.fromInt(Int.fromNat(Nat8.toNat(b))) / 255.0 + 0.5;
                    };
                    
                    (k, {
                        id = v.id;
                        size = v.size + growthRate;
                        color = v.color;
                        pattern = v.pattern;
                        growing = v.growing;
                    })
                } else {
                    (k, v)
                };
            }
        );
    };

    private func growCrystal(id: Nat) : async () {
        crystals := await updateCrystalGrowth(id);
    };

    private func getCrystal(id: Nat) : Crystal {
        switch (Array.find<(Nat, Crystal)>(crystals, func((k, _)) = k == id)) {
            case null { { id = 0; size = 0.0; color = ""; pattern = 0; growing = false } };
            case (?(_, crystal)) crystal;
        };
    };

    public func toggleGrowth(id: Nat) : async () {
        crystals := Array.map<(Nat, Crystal), (Nat, Crystal)>(
            crystals,
            func((k, v)) : (Nat, Crystal) {
                if (k == id) {
                    (k, {
                        id = v.id;
                        size = v.size;
                        color = v.color;
                        pattern = v.pattern;
                        growing = not v.growing;
                    })
                } else {
                    (k, v)
                };
            }
        );
    };

    public query func getCrystals() : async [Crystal] {
        Array.map<(Nat, Crystal), Crystal>(crystals, func((_, v)) = v);
    };
}
