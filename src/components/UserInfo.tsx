import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import React from "react";

export function OwnedObjects() {
  const account = useCurrentAccount();

  const { data } = useSuiClientQuery("getOwnedObjects", {
    owner: account?.address as string,
  });
  if (!data) {
    return null;
  }

  return (
    <ul>
      {data.data.map((object) => (
        <li key={object.data?.objectId}>
          <a href={`https://suiexplorer.com/object/${object.data?.objectId}`}>
            {object.data?.objectId}
          </a>
        </li>
      ))}
    </ul>
  );
}
