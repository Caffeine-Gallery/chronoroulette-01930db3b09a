export const idlFactory = ({ IDL }) => {
  const Crystal = IDL.Record({
    'id' : IDL.Nat,
    'pattern' : IDL.Nat,
    'color' : IDL.Text,
    'size' : IDL.Float64,
    'growing' : IDL.Bool,
  });
  return IDL.Service({
    'createCrystal' : IDL.Func([], [IDL.Nat], []),
    'getCrystals' : IDL.Func([], [IDL.Vec(Crystal)], ['query']),
    'toggleGrowth' : IDL.Func([IDL.Nat], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
