//
//  NetUtils.cpp
//  test2
//
//  Created by user on 5/12/20.
//  Copyright © 2020 user. All rights reserved.
//
#include <iostream>
#include <boost/asio.hpp>
#include <cstdlib>
#include <string>
#include <iostream>
#include <iomanip>
#include "NetUtils.hpp"

using namespace std;
using boost::asio::ip::tcp;

#define HOST "google.com"
#define PORT 80

const string SERVER_DOMAIN = "google.com";

int sendRequest2Server(const char *data){
    try
    {
        // Check command line arguments.
        auto const host = "192.168.0.107";
        auto const url = "/api/ios/defect";
        
        boost::asio::io_service io_service;
        
        // Get a list of endpoints corresponding to the server name.
        tcp::resolver resolver(io_service);
        tcp::resolver::query query(host, "http");
        tcp::resolver::iterator endpoint_iterator = resolver.resolve(query);
        
        // Try each endpoint until we successfully establish a connection.
        tcp::socket socket(io_service);
        boost::asio::connect(socket, endpoint_iterator);
        
        //Body
        string json = string(data);
        
        // Form the request. We specify the "Connection: close" header so that the
        // server will close the socket after transmitting the response. This will
        // allow us to treat all data up until the EOF as the content.
        boost::asio::streambuf request;
        std::ostream request_stream(&request);
        request_stream << "POST " << url << " HTTP/1.0\r\n";
        request_stream << "Host: " << host << "\r\n";
        request_stream << "Accept: */*\r\n";
        request_stream << "Content-Length: " << json.length() << "\r\n";
        request_stream << "Connection: close\r\n\r\n";
        request_stream << json;
        
        // Send the request.
        boost::asio::write(socket, request);
        
        // Read the response status line. The response streambuf will automatically
        // grow to accommodate the entire line. The growth may be limited by passing
        // a maximum size to the streambuf constructor.
        boost::asio::streambuf response;
        boost::asio::read_until(socket, response, "\r\n");
        
        // Check that response is OK.
        std::istream response_stream(&response);
        
        std::string http_version;
        response_stream >> http_version;
        unsigned int status_code;
        response_stream >> status_code;
        std::string status_message;
        std::getline(response_stream, status_message);
        
        if (!response_stream || http_version.substr(0, 5) != "HTTP/")
        {
            std::cout << "Invalid response\n";
            return -1;
        }
        if (status_code != 200)
        {
            std::cout << "Response returned with status code " << status_code << "\n";
            return -1;
        }

        if (response.size() > 0){
            // parsing the headers and get body of response
            string line;
            while (getline(response_stream, line, '\n')) {
                if (line.empty() || line == "\r")
                    break;
                
                if (line.back() == '\r')
                    line.resize(line.size()-1);
            }
        }
        
        string const body(std::istreambuf_iterator<char>{response_stream}, {});
        
        return std::stoi(body);
        
    }
    catch (std::exception& e)
    {
        std::cout << "Exception: " << e.what() << "\n";
    }
    
    return -1;
}
