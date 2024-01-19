import { useSuiClientQuery } from "@mysten/dapp-kit";

export const useGetGameInfo = () => {
  function getGameInfo(game_id) {
    const id: string = game_id;

    const { data, isLoading, error, refetch } = useSuiClientQuery("getObject", {
      id,
      options: {
        showContent: true,
        showOwner: true,
      },
    });

    return { data, isLoading, error, refetch };
  }
  return { getGameInfo };
};
