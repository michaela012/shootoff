import { useSuiClientQuery } from "@mysten/dapp-kit";

// [Q] Why is this wrapped
export const useGetGameInfo = () => {
  const handleGetGameInfo = () => {
    // TODO: user's active game
    const id: string = "<ACTIVE_GAME_ID>";

    const { data, isLoading, error, refetch } = useSuiClientQuery("getObject", {
      id,
      options: {
        showContent: true,
        showOwner: true,
      },
    });

    return { data, isLoading, error, refetch };
  };

  return { handleGetGameInfo };
};
