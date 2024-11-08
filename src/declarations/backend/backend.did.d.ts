import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Crystal {
  'id' : bigint,
  'pattern' : bigint,
  'color' : string,
  'size' : number,
  'growing' : boolean,
}
export interface _SERVICE {
  'createCrystal' : ActorMethod<[], bigint>,
  'getCrystals' : ActorMethod<[], Array<Crystal>>,
  'toggleGrowth' : ActorMethod<[bigint], undefined>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
