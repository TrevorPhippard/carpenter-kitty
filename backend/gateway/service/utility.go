package proto

import (
	"context"
	"fmt"
	"log"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func UserServiceClientConn(addr string, userID uint64) string {
	conn, err := grpc.Dial(
		addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithBlock(),
	)
	if err != nil {
		log.Printf("Failed to connect to user service: %v", err)
		return "error"
	}
	defer conn.Close()

	client := NewUserServiceClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	resp, err := client.GetUser(ctx, &GetUserRequest{Id: userID})
	if err != nil {
		log.Printf("gRPC error: %v", err)
		return "UserService Error"
	}

	return resp.User.Name
}

func PostServiceClientConn(addr string, postID uint64) string {
	conn, err := grpc.Dial(
		addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
		grpc.WithBlock(),
	)
	if err != nil {
		log.Printf("Failed to connect to PostService: %v", err)
		return "error"
	}
	defer conn.Close()

	client := NewPostServiceClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	resp, err := client.GetPost(ctx, &PostId{Id: fmt.Sprintf("%d", postID)})
	if err != nil {
		log.Printf("gRPC error: %v", err)
		return "PostService Error"
	}

	return resp.AuthorId
}

// func ConnectionsServiceClientConn(addr string) string {
// 	conn, err := grpc.Dial(
// 		addr,
// 		grpc.WithTransportCredentials(insecure.NewCredentials()),
// 		grpc.WithBlock(),
// 	)
// 	if err != nil {
// 		log.Printf("Failed to connect to ConnectionsService: %v", err)
// 		return "error"
// 	}
// 	defer conn.Close()

// 	client := NewConnectionsServiceClient(conn)

// 	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
// 	defer cancel()

// 	resp, err := client.Ping(ctx, &Empty{})
// 	if err != nil {
// 		log.Printf("ConnectionsService error: %v", err)
// 		return "ConnectionsService Error"
// 	}

// 	return resp.Message
// }
